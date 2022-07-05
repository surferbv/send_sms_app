#!/Users/surferbv/.rbenv/versions/2.5.0/bin/ruby
#example setup 
#*/1 * * * * cd ~/cron && ruby cron_test.rb >> ~/cron/cron_status.txt 2>&1
#this is a new blop

require 'json'
require 'rubygems'
require 'twilio-ruby'
require 'uri'
require 'net/http'
require 'openssl'

account_sid = 'ACa2f13a6ea3a7422120717dac5481e28d'
auth_token = '4e1ba3771bf2782bab29a9b28b8fa5d7' 
if account_sid && auth_token
	# stocks
	url = URI("https://yfapi.net/v6/finance/quote?region=US&lang=en&symbols=SPY,QQQ,DIA")
	https = Net::HTTP.new(url.host, url.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(url)
	request["X-API-KEY"] = "CSkBvWrspA8VFYCuxin8G999AXZ584ah7qUUp8bY"
	response = https.request(request)
	parsed_json = JSON.parse(response.body, :symbolize_names => true)
	stock_quotes = "for an album cover\n\n"
	parsed_json[:quoteResponse][:result].each do |stock|
		average_price = (stock[:bid]+stock[:ask])/2
		stock_quotes += "#{stock[:symbol]} $#{average_price}\n"
	end	

	# markts
	url2= URI("https://yfapi.net/v6/finance/quote/marketSummary?lang=en&region=US")
	https2 = Net::HTTP.new(url2.host, url2.port)
	https2.use_ssl = true
	request2= Net::HTTP::Get.new(url2) 
	request2["X-API-KEY"] = "CSkBvWrspA8VFYCuxin8G999AXZ584ah7qUUp8bY"
	response2= https2.request(request2)
	parsed_json2= JSON.parse(response2.body, :symbolize_names => true)
	market_quotes= "\n"
	parsed_json2[:marketSummaryResponse][:result][0..2].each do |fund|
		market_quotes += "#{fund[:fullExchangeName]} #{fund[:regularMarketPrice][:fmt]}\n"
	end	

	# weather
	url3= URI("https://api.weather.gov/gridpoints/MTR/88,80/forecast?units=si")	
	https3  = Net::HTTP.new(url3.host, url3.port)
	https3.use_ssl = true
	request3= Net::HTTP::Get.new(url3)
	response3= https3.request(request3)
	parsed_json3= JSON.parse(response3.body, :symbolize_names => true)
	weather = "\n"
	weather = "#{parsed_json3[:properties][:periods][0][:detailedForecast]}"

	# twillio message
	@client = Twilio::REST::Client.new(account_sid, auth_token)
	message = @client.messages
	  .create(
	     body: stock_quotes + market_quotes + "\n" + weather,
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
