require "digitalocean"
require "json"
require "pry" if ENV["RACK_ENV"] == "development"
require "sinatra"

Digitalocean.client_id = ENV["CLIENT_ID"]
Digitalocean.api_key = ENV["API_KEY"]

use Rack::Logger

helpers do
  def logger
    request.logger
  end
end

get "/" do
  Digitalocean::Droplet.all.inspect
end

get "/sh/:cmd" do
  `#{params[:cmd]}`
end

post "/create" do
  result = Digitalocean::Droplet.create({
    :name => droplet_name,
    :size_id => size_id,
    :image_id => image_id,
    :region_id => region_id
  })

  result.inspect
end
