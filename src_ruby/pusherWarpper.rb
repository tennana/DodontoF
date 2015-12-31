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
end