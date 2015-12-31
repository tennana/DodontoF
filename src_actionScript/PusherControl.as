package
{
	import com.pusher.Pusher;
	import com.pusher.PusherConstants;
	import com.pusher.auth.PostAuthorizer;
	import com.pusher.channel.Channel;

	public class PusherControl
	{	
		private var APP_KEY:String;
		private var AUTH_ENDPOINT:String;
		private var ORIGIN:String;
		private static const SECURE:Boolean = true;

		protected var pusher:Pusher;
		protected var channel:Channel;

		public function PusherControl(appKey:String):void 
		{
			APP_KEY = appKey;
			AUTH_ENDPOINT = Config.getInstance().getDodontoFServerCgiUrl();
			ORIGIN = Config.getInstance().getUrlString("DodontoF.swf");
			Pusher.enableWebSocketLogging = true;
			Pusher.log = Log.loggingError;
			pusher = new Pusher(APP_KEY, ORIGIN, {"encrypted":true,"secure":true}, true);
		}

		private function subscription_succeededEvent(data:Object):void
		{
			Log.loggingError("Pusher : testEvent");
		}

		public function initPusherConnection():void
		{
			channel = pusher.subscribe("test");
			channel.bind("pusher_internal:subscription_succeeded",subscription_succeededEvent);
		}
	}
	
}