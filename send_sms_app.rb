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
require 'pry'
require 'secret_keys'
require 'byebug'

secrets = SecretKeys.new("credentials.yaml", ENV['SMS_KEY'])
account_sid = secrets['api_keys']['TWILIO_ACCOUNT_SID']
auth_token = secrets['api_keys']['TWILIO_AUTH_TOKEN']
marketstack_key = secrets['api_keys']['MARKETSTACK']

Response = Struct.new( :code, :body)

def fetch_it(caller, http_req)
	http    = http_req[:http]
	request = http_req[:request]

	i = 0
	begin
		actual_response = http.request(request)
		response = Response.new('','')
		response.code = actual_response.code
		i+=1
	end until response.code == '200' || i > 4

	if actual_response.is_a?(Net::HTTPSuccess)
		response.body = JSON.parse(actual_response.body, :symbolize_names => true)
	else
		response.body = caller
	end
	response
end

def build_http_req(url, params, is_use_ssl = false, is_verify_mod = false)
	url = URI(url)
	url.query = URI.encode_www_form(params)

	http = Net::HTTP.new(url.host, url.port)
	request = Net::HTTP::Get.new(url)

	http.use_ssl = is_use_ssl
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE if is_verify_mod

	return {http: http, request: request}
end

if account_sid && auth_token
	result = "Stock and weather report\n\n"

	# stocks
	caller = "Stock api "
	url = "http://api.marketstack.com/v1/eod"
  dia_params = {access_key: marketstack_key, symbols: 'DIA', limit: 1}
  spy_params = {access_key: marketstack_key, symbols: 'SPY', limit: 1}
  qqq_params = {access_key: marketstack_key, symbols: 'QQQ', limit: 1}

  stock_params = [dia_params, spy_params, qqq_params]

  # build http request and fetch it
  stock_params.each do |stock_param|
		http_req = build_http_req(url, stock_param)
		response = fetch_it(caller + stock_param[:symbols], http_req)

		if response.code == '200'
			response.body[:data].each do |stock|
				average_price = (stock[:high]+stock[:low])/2
				result += "#{stock[:symbol]} $#{average_price}\n"
			end
			puts "Successful response from stock api\n\n"
		else
			res = response.body + response.code
			result += res
			puts "Failed to call and parsed stock api"
			puts "#{res} \n\n"
		end
	end

	# weather
	caller = "Weather api "
	url = "https://api.weather.gov/gridpoints/MTR/88,80/forecast"
  weather_params = {units: 'si'}

  # build http request and fetch it
  http_req = build_http_req(url, weather_params, true, true)
	response = fetch_it(caller, http_req)

	if response.code == '200' && !response.is_a?(String)
		puts "Successful response from weather api\n\n"
		result += "\n"
		response.body.key?(:properties) ? result : result += "#{caller} properties missing\n"
		response.body[:properties].key?(:periods) ? result : result += "#{caller} periods missing\n\n"
    result += "#{response.body[:properties][:periods][0][:detailedForecast]}" if !result.include?("missing")
  else
    res = response.body + response.code
		result += res
		puts "Failed to call and parsed weather api"
    puts "#{res} \n\n"
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
