package
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import com.pusher.Pusher;
	import com.pusher.PusherConstants;
	import com.pusher.auth.PostAuthorizer;
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
		private var typingTimer:Timer = null;
		private var typingTimeoutsec:uint = 60;

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
			if (jsonData.Pusher_typingTimeoutsec) {
				typingTimeoutsec = uint(jsonData.Pusher_typingTimeoutsec);
			}
			AUTH_ENDPOINT = Config.getInstance().getDodontoFServerCgiUrl();
			ORIGIN = Config.getInstance().getUrlString("DodontoF.swf");
			Pusher.enableWebSocketLogging = true;
			Pusher.log = Log.logging;
			pusher = new Pusher(APP_KEY, ORIGIN, {"encrypted":true,"secure":true}, true);
			Pusher.authorizer = new PostAuthorizer(AUTH_ENDPOINT);
		}

		private function subscription_succeededEvent(data:Object):void
		{
			Log.initLogWindow();
		}

		public function initPusherConnection():void
		{
			channel = pusher.subscribe("test");
			channel.bind("pusher_internal:subscription_succeeded",subscription_succeededEvent);
			channel.bind("typingEvent", typingEvent);
		}

		private function typingEvent(data:Object):void {
			typingList.push( { "time":uint(new Date().getTime() / 1000 + typingTimeoutsec), "name":data.name } );
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

			if (typingTimer != null) {
				typingTimer.stop();
			}
			typingTimer = new Timer((newTypingList[0].time - nowTime + 1) * 1000,1);
			typingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, updateTypingList);
			typingTimer.start();

			return typingList.length;
		}
	}
	
}