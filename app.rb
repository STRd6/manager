require "digitalocean"
require "json"
require "pry" if ENV["RACK_ENV"] == "development"
require "sinatra"

Digitalocean.client_id = ENV["CLIENT_ID"]
Digitalocean.api_key = ENV["API_KEY"]

use Rack::Logger

def exec(cmd)
  content_type :txt

  cmd = "(#{cmd}) 2>&1"

  logger.info(cmd)

  io = IO.popen(cmd)
  io.sync = true

  io
end

def host_exec(cmd)
  hostname = ENV["HOSTNAME"] || "cloudpeninsula.com"
  cmd = "ssh -i ~/.ssh/id_rsa -o ConnectTimeout=1 -o BatchMode=yes -o StrictHostKeyChecking=no #{hostname} #{cmd}"

  exec(cmd)
end

def env_file(app)
  "/home/git/#{app}/ENV"
end

helpers do
  def logger
    request.logger
  end
end

get "/" do
  Digitalocean::Droplet.all.inspect
end

get "/sh/:cmd" do
  exec(params[:cmd])
end

get "/ssh/:cmd" do
  host_exec(params[:cmd])
end

get "/setenv/:app/:key/:value" do
  file = env_file(params[:app]})

  key = params[:key]
  value = params[:value]

  host_exec("\"echo 'export #{key}=#{value}' >> #{env_file}\"")
end

get "/env/:app" do
  file = env_file(params[:app])

  host_exec("cat #{env_file}")
end

get "/id_rsa.pub" do
  content_type :txt

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
