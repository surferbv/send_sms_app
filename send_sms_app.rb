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
auth_token = 'd6d5b7cae39a4790f316967af28b05d0' 

def fetch_it(caller, url, key = '')
	parsed_json = ''
	uri_url = URI(url)
	https = Net::HTTP.new(uri_url.host, uri_url.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(uri_url)
	request["X-API-KEY"] = key if !key.empty?
	response = https.request(request)
	if response.is_a?(Net::HTTPSuccess)
		parsed_json = JSON.parse(response.body, :symbolize_names => true)
	else
		parsed_json = caller + " " + response.code
	end
	parsed_json
end

if account_sid && auth_token

	# stocks
	caller = "Stock call"
	url = "https://yfapi.net/v6/finance/quote?region=US&lang=en&symbols=SPY,QQQ,DIA"
	key = "XH0aRuUjD22JnrmyJQSTL53LaKbxG7XdNb7xUfl5"
	parsed_json = fetch_it(caller, url, key)
	
	stock_quotes = "for an album cover\n\n"
	parsed_json[:quoteResponse][:result].each do |stock|
		average_price = (stock[:bid]+stock[:ask])/2
		stock_quotes += "#{stock[:symbol]} $#{average_price}\n"
	end	

	# markts
	caller = "Market call"
	url = "https://yfapi.net/v6/finance/quote/marketSummary?lang=en&region=US"
	key = "XH0aRuUjD22JnrmyJQSTL53LaKbxG7XdNb7xUfl5"
	parsed_json2 = fetch_it(caller, url, key)
	
	market_quotes= "\n"
	parsed_json2[:marketSummaryResponse][:result][0..2].each do |fund|
		market_quotes += "#{fund[:fullExchangeName]} #{fund[:regularMarketPrice][:fmt]}\n"
	end	

	# weather
	caller = "Weather call"
	url = "https://api.weather.gov/gridpoints/MTR/88,80/forecast?units=si"
	parsed_json3= fetch_it(caller, url, key)
	
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
