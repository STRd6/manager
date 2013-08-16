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
  logger.info params[:cmd]

  content_type :txt

  io = IO.popen("#{params[:cmd]} 2>&1")
  io.sync = true

  io
end

get "/ssh/:cmd" do
  io = IO.popen("ssh -i ~/.ssh/id_rsa -o ConnectTimeout=1 -o BatchMode=yes -o StrictHostKeyChecking=no #{params[:cmd]} 2>&1")
  io.sync = true

  io
end

get "/id_rsa.pub" do
  `scripts/gen_pub`

  `more ~/.ssh/id_rsa.pub`
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
