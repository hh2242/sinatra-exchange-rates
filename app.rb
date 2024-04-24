require "sinatra"
require "sinatra/reloader"
require 'net/http'
require 'json'

def fetch_resource(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  request = Net::HTTP::Get.new(uri)
  response = http.request(request)
  
  if response.code == '200'
    return JSON.parse(response.body)
  else
    return nil
  end
end

get("/") do
  body = fetch_resource("https://api.exchangerate.host/list?access_key=#{ENV.fetch("EXCHANGE_RATE_KEY")}")
  currencies = body['currencies'].keys()

  @items = currencies

  erb(:home)
end

get("/:from_currency") do
  @currency = params.fetch("from_currency")

  api_url = "https://api.exchangerate.host/list?access_key=#{ENV.fetch("EXCHANGE_RATE_KEY")}"
  body = fetch_resource(api_url)

  @items = body['currencies'].keys()

  erb(:first)
end

get("/:from_currency/:to_currency") do
  @first = params.fetch("from_currency")
  @second = params.fetch("to_currency")

  api_url = "https://api.exchangerate.host/convert?access_key=#{ENV.fetch("EXCHANGE_RATE_KEY")}&from=#{@first}&to=#{@second}&amount=1"

  body = fetch_resource(api_url)

  @amount = body['result']
  
  erb(:second)
end
