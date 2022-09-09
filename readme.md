# Weather and Stock SMS Notifier 
Simple project that sends you a sms with details about the current weather and stock market. 

## Configuration

You will need to create accounts from the following services and get familiar with their documentation.

APIs:

Twilio:
https://www.twilio.com/try-twilio

TwelveData: https://twelvedata.com/login

Weather Service: https://www.weather.gov/documentation/services-web-api

Its a simple ruby script so all you will need is the correct version of 
ruby and install the gems using the `bundle install`

This script uses Twilio api to send sms, twelvedata stock api, national weather service api. 
You will need to create an account for each except for national weather service which is free. 

This project uses `secret_keys` to encrypt api keys, tokens, and other account details. You can read more about 
it here https://github.com/bdurand/secret_keys.

Oh and don't forget to change the from: and to: numbers. 

## Installation

1. Install ruby `ruby '3.1.0'`
2. Clone repo
3. Install gems with bundler `bundle install`
4. Add your own Twilio credentials i.e. `TWILIO_AUTH_TOKEN`, `TWILIO_ACCOUNT_SID`, and `TWELVE`. 

## Running   

``ruby send_sms_app.rb``

Feel free to run this as a cron job or schedule on Heroku other other service. 
