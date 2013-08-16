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
  content_type :txt
  IO.popen(params[:cmd])
end

get "/id_rsa.pub" do
  # Make sure ssh is installed
  `apt-get install ssh -y`
  `mkdir ~/.ssh`
  `cd ~/.ssh && ssh-keygen -f id_rsa -C 'MGMT' -N '' -t rsa -q && cd ..`
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
