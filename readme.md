# Weather and Stock SMS Notifier 
Simple project that sends a sms with details about the current weather and stock market quotes. 

## Configuration

You will need to create accounts from the following services and get familiar with their documentation. 
This script uses Twilio api to send sms, twelvedata stock api, national weather service api. 
This project uses [secret_keys](https://github.com/bdurand/secret_keys) to encrypt api keys, tokens, and other account details. 
You will need to create an account for each except for national weather service which is free. 

#### APIs:

Twilio:
https://www.twilio.com/try-twilio

TwelveData: https://twelvedata.com/login

Weather Service: https://www.weather.gov/documentation/services-web-api

## Installation

1. Install ruby based on the gemfile 
2. Clone repo
3. Install gems with bundler `bundle install`
4. Add your own Twilio credentials i.e. `TWILIO_AUTH_TOKEN`, `TWILIO_ACCOUNT_SID`, and `TWELVE`.
5. Change from: and to: number 

## Running   

``ruby send_sms_app.rb``

## Useful Commands

secret_keys commands:

Generating encrypted file:

`secret_keys init --secret=<password> credentials.yaml`

Encrypting file:

`secret_keys encrypt -s <password> --encrypt-all --in-place credentials.yaml`

Decrypting file:

`secret_keys decrypt --secret <password> credentials.yaml`
