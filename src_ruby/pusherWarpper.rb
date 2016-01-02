require 'rubygems'
require 'Pusher'

Pusher.url = $Pusher_API_URL

module PusherWarpper
	def test
		logging('loginOnWebInterface Begin'+$Pusher_API_URL)
		Pusher.trigger('test_channel', 'my_event', {
		  message: 'hello world'
		})
	end
	module_function :test
	def auth(params)
		logging('loginOnWebInterface Begin'+$Pusher_API_URL)
		logging(params, "params")
		result = Pusher.authenticate(params['channel_name'], params['socket_id'], {
		  user_id: params['uniqueId'],
		  user_info: {} # optional
		})
		logging(result);
		return result;
	end
	module_function :auth
end