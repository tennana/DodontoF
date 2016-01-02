package
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import com.pusher.Pusher;
	import com.pusher.PusherConstants;
	import com.pusher.auth.PostMsgPackAuthorizer;
	import com.pusher.channel.Channel;

	public class PusherControl
	{	
		private var APP_KEY:String;
		private var AUTH_ENDPOINT:String;
		private var ORIGIN:String;
		private var Pusher_Channel_prefix:String = "";
		private var canUsePusher_ClientEvent:Boolean = false;
		private static const SECURE:Boolean = true;

		private var typingList:Array = [];
		private var typingTimeoutSec:uint = 6;
		private var typingTimeoutInErrorSec:uint = 60;
		private var typingSendTimer:Timer = null;
		private var typingStateTimer:Timer = null;
		private var typingListener:Object = new Object();
		private var typingEventSending:Boolean = false;

		protected var pusher:Pusher;
		protected var channel:Channel;

		public function PusherControl(jsonData:Object):void 
		{
			APP_KEY = jsonData.Pusher_APP_ID;
			if(jsonData.Pusher_Channel_prefix){
				Pusher_Channel_prefix = jsonData.Pusher_Channel_prefix;
			}
			if (jsonData.canUsePusher_ClientEvent) {
				canUsePusher_ClientEvent = true;
			}
			if (jsonData.Pusher_typingTimeoutInErrorSec) {
				typingTimeoutInErrorSec = uint(jsonData.Pusher_typingTimeoutsec);
			}
			AUTH_ENDPOINT = Config.getInstance().getDodontoFServerCgiUrl();
			ORIGIN = Config.getInstance().getUrlString("DodontoF.swf");
			Pusher.enableWebSocketLogging = true;
			Pusher.log = Log.logging;
			Pusher.authorizer = new PostMsgPackAuthorizer(AUTH_ENDPOINT);
			pusher = new Pusher(APP_KEY, ORIGIN, {"encrypted":true,"secure":true}, false);
		}

		private function channel_member_changed(data:Object):void
		{
			// 部屋情報の再取得とかさせたくない？
		}

		private function channel_member_removed(data:Object):void
		{
			removeTypingList(data.user_id);
		}

		private function subscription_succeededEvent(data:Object):void
		{
			DodontoF_Main.getInstance().getChatWindow().chatMessageInput.addEventListener(KeyboardEvent.KEY_DOWN , typingKeyDownFunc);
			DodontoF_Main.getInstance().getChatWindow().chatMessageInput.addEventListener(KeyboardEvent.KEY_UP , typingKeyUpFunc);
		}

		public function initPusherConnection():void
		{
			channel = pusher.subscribeAsPresence("DodontoF-"+Pusher_Channel_prefix+DodontoF_Main.getInstance().getPlayRoomNumber());
			channel.bind("pusher_internal:subscription_succeeded",subscription_succeededEvent);
			channel.bind("pusher_internal:member_added",channel_member_changed);
			channel.bind("pusher_internal:member_removed",channel_member_changed);
			channel.bind("pusher_internal:member_removed", channel_member_removed);
			if(canUsePusher_ClientEvent){
				channel.bind("client-typingStartEvent", typingStartEvent);
				channel.bind("client-typingEndEvent", typingEndEvent);
			} else {
				channel.bind("typingStartEvent", typingStartEvent);
				channel.bind("typingEndEvent", typingEndEvent);
			}
			pusher.connect();
		}

		private function typingStartEvent(data:Object):void {
			typingList.push( { "time":uint(new Date().getTime() / 1000 + typingTimeoutInErrorSec), "name":data.name , "uniqueId":data.uniqueId} );
			updateTypingList();
		}

		public function typingEndEvent(data:Object):void
		{
			removeTypingList(data.uniqueId);
		}

		public function removeTypingList(uniqueId:String):void
		{
			var i:uint;
			for (i = 0; i < typingList.length; i++) {
				if(typingList[i].uniqueId == uniqueId){
					typingList[i].time = -1;
				}
			}
			updateTypingList();
		}

		public function updateTypingList(e:TimerEvent = null):int
		{
			var i:uint;
			var newTypingList:Array = [];
			var nowTime:uint = uint(new Date().getTime() / 1000);
			for (i = 0; i < typingList.length; i++) {
				if (typingList[i].time > nowTime) {
					newTypingList.push(typingList[i]);
				}
			}
			newTypingList.sortOn("time", Array.NUMERIC);
			
			typingList = newTypingList;

			if (typingList.length == 0) {
				DodontoF_Main.getInstance().getChatWindow().typingStatus.text = "";
				return 0;
			}
			var sTyping:String = "入力中:";
			for (i = 0; i < typingList.length; i++) {
				if (i > 0) sTyping += "、";
				sTyping += typingList[i].name;
			}
			
			DodontoF_Main.getInstance().getChatWindow().typingStatus.text = sTyping;

			if(!canUsePusher_ClientEvent){
				if (typingStateTimer != null) {
					typingStateTimer.stop();
				}
				typingStateTimer = new Timer((newTypingList[0].time - nowTime + 1) * 1000,1);
				typingStateTimer.addEventListener(TimerEvent.TIMER_COMPLETE, updateTypingList);
				typingStateTimer.start();
			}

			return typingList.length;
		}
		
		private function typingKeyUpFunc(event:KeyboardEvent):void
		{
			if( typingSendTimer == null ){
			} else if ( event.keyCode == Keyboard.ENTER && !event.shiftKey && !event.ctrlKey) {
				DodontoF_Main.getInstance().getChatWindow().chatMessageInput.callLater(function ():void{
					if(DodontoF_Main.getInstance().getChatWindow().chatMessageInput.text == ""){
						sendTypingEnd();
					} else {
						typingSendTimer.start();
					}
				});
		        } else if (! typingSendTimer.running ) {
				typingSendTimer.start();
			}
		}
		
		private function typingKeyDownFunc(event:KeyboardEvent):void
		{
			if( event.keyCode == Keyboard.ENTER ) {
				return;
			} else if(!(
				(event.keyCode >= 37 && event.keyCode <= 40) ||
				(event.keyCode >= 48 && event.keyCode <= 111) ||
				(event.keyCode == Keyboard.BACKSPACE) ||
				(event.keyCode == Keyboard.DELETE) ||
				(event.keyCode == Keyboard.SPACE) ||
				(event.keyCode == 229)
			)){
				return;
			} else if (typingSendTimer != null && typingSendTimer.currentCount < 1) {
				typingSendTimer.reset();
				if(event.keyCode == 229)
					typingSendTimer.start(); // IMEェ
				return;
			} else if (typingEventSending && typingSendTimer != null) {
				return;
			}
			var sendEventData:Object = { "name" : DodontoF_Main.getInstance().getChatWindow().getChatCharacterName(), "uniqueId" : DodontoF_Main.getInstance().getUniqueId() };
			if (canUsePusher_ClientEvent) {
				pusher.sendEvent("client-typingStartEvent", sendEventData , channel.name);
			} else {
				
			}
			typingEventSending = true;
			typingStartEvent(sendEventData); // 自分を表示する場合
			if(typingSendTimer != null){
				typingSendTimer.stop();
				typingSendTimer = null;
			}
			typingSendTimer = new Timer(typingTimeoutSec * 1000, 1);
			typingSendTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendTypingEnd);
		}
		
		private function sendTypingEnd(e:TimerEvent = null):void
		{
			var sendEventData:Object = { "uniqueId" : DodontoF_Main.getInstance().getUniqueId() };
			if (canUsePusher_ClientEvent) {
				pusher.sendEvent("client-typingEndEvent", sendEventData  , channel.name);
			} else {
				
			}
			typingEndEvent(sendEventData);
			if(typingSendTimer != null){
				typingSendTimer.stop();
				typingSendTimer = null;
			}
			typingEventSending = false;
		}
	}
}