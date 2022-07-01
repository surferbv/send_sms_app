require 'rubygems'
require 'twilio-ruby'

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
if account_sid && auth_token
	@client = Twilio::REST::Client.new(account_sid, auth_token)
	message = @client.messages
	  .create(
	     body: 'This is the ship that made the Kessel Run in fourteen parsecs? Yeah sure!',
	     from: '+19472256784',
	     to: '+16505358869'
	   )

	puts message.sid
else
	puts "auth token or account sid is missing"
	puts "auth: #{auth_token}"
	puts "account sid: #{account_sid}"
end

