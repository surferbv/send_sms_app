#!/Users/surferbv/.rbenv/versions/2.5.0/bin/ruby
#example setup 
#*/1 * * * * cd ~/cron && ruby cron_test.rb >> ~/cron/cron_status.txt 2>&1

require 'json'
require 'rubygems'
require 'twilio-ruby'
require 'uri'
require 'net/http'
require 'openssl'

account_sid = 'ACa2f13a6ea3a7422120717dac5481e28d'
auth_token = '4fdf3fce1e05e7784d4538e80a721de2' 
if account_sid && auth_token
	url = URI("https://yfapi.net/v6/finance/quote?region=US&lang=en&symbols=SPY,QQQ,DIA")
	url2= URI("https://yfapi.net/v6/finance/quote/marketSummary?lang=en&region=US")

	https = Net::HTTP.new(url.host, url.port)
	https.use_ssl = true

	request = Net::HTTP::Get.new(url)
	request2= Net::HTTP::Get.new(url2) 

	request["X-API-KEY"] = "CSkBvWrspA8VFYCuxin8G999AXZ584ah7qUUp8bY"
	request2["X-API-KEY"] = "CSkBvWrspA8VFYCuxin8G999AXZ584ah7qUUp8bY"
	
	response = https.request(request)
	response2= https.request(request2)

	parsed_json = JSON.parse(response.body, :symbolize_names => true)
	parsed_json2= JSON.parse(response2.body, :symbolize_names => true)

	stock_quotes = "for anal bum cover\n"
	market_quotes= ""

	parsed_json[:quoteResponse][:result].each do |stock|
		average_price = (stock[:bid]+stock[:ask])/2
		stock_quotes += "#{stock[:symbol]} $#{average_price}\n"
	end		
	
	parsed_json[:marketSummaryResponse][:result][0..3].each do |fund|
		market_quotes += "#{fund[:fullExchangeName]}\n"
	end		

	@client = Twilio::REST::Client.new(account_sid, auth_token)
	message = @client.messages
	  .create(
	     body: stock_quotes + market_quotes,
	     from: '+19472256784',
	     to: '+16505358869'
	   )

	puts "Message was successfully sent!"
	puts "SID: #{message.sid}"
else
	puts "auth token or account sid is missing"
	puts "auth: #{auth_token}"
	puts "account sid: #{account_sid}"
end
