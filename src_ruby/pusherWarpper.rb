require 'rubygems'
require 'pusher'

Pusher.url = $Pusher_API_URL

module PusherWarpper
	def auth(params)
		result = Pusher.authenticate(params['channel_name'], params['socket_id'], {
		  :user_id => params['uniqueId'],
		})
		return result;
	end
	module_function :auth
end