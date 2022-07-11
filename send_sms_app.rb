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
auth_token = '3c6b003b04eb668aa41e731b26f72f0b' 

def fetch_it(caller, url, key = '')
	response = Struct.new( :code, :response)
	parsed_json = response.new('','')
	uri_url = URI(url)
	https = Net::HTTP.new(uri_url.host, uri_url.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(uri_url)
	request["X-API-KEY"] = key if !key.empty?
	response = https.request(request)
	if response.is_a?(Net::HTTPSuccess)
		parsed_json.code = response.code
		parsed_json.response = JSON.parse(response.body, :symbolize_names => true)
	else
		parsed_json.code = response.code
		parsed_json.response = caller
	end
	parsed_json
end

if account_sid && auth_token
	result = ""

	# stocks
	caller = "Stock call"
	url = "https://yfapi.net/v6/finance/quote?region=US&lang=en&symbols=SPY,QQQ,DIA"
	key = "XH0aRuUjD22JnrmyJQSTL53LaKbxG7XdNb7xUfl5"
	parsed_json = fetch_it(caller, url, key)
	
	if parsed_json.code == '200'
		result += "for an album cover\n\n"
		parsed_json.response[:quoteResponse][:result].each do |stock|
			average_price = (stock[:bid]+stock[:ask])/2
			result += "#{stock[:symbol]} $#{average_price}\n"
		end	
	
	else
		result += parsed_json.response + parsed_json.code
	end

	# markts
	caller = "Market call"
	url = "https://yfapi.net/v6/finance/quote/marketSummary?lang=en&region=US"
	key = "XH0aRuUjD22JnrmyJQSTL53LaKbxG7XdNb7xUfl5"
	parsed_json = fetch_it(caller, url, key)

	if parsed_json.code == '200'
		result += "\n"
		parsed_json.response[:marketSummaryResponse][:result][0..2].each do |fund|
			result += "#{fund[:fullExchangeName]} #{fund[:regularMarketPrice][:fmt]}\n"
		end	
	else
		result += parsed_json.response + parsed_json.code
	end
	
	# weather
	caller = "Weather call"
	url = "https://api.weather.gov/gridpoints/MTR/88,80/forecast?units=si"
	parsed_json = fetch_it(caller, url, key)

	if parsed_json.code = '200'
		result += "\n"
		result += "#{parsed_json.response[:properties][:periods][0][:detailedForecast]}"
	else
		result += parsed_json.response + parsed_json.code
	end
	
	# twillio message
	@client = Twilio::REST::Client.new(account_sid, auth_token)
	message = @client.messages
	  .create(
	     body: result,
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
