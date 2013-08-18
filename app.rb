require "digitalocean"
require "json"
require "pry" if ENV["RACK_ENV"] == "development"
require "sinatra"
require "./workers"

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

# TODO: Switch this to POST because setting long env variable doesn't work
def setenv(app, key, value)
  file = env_file(app)

  host_exec("\"echo 'export #{key}=\\\"#{value}\\\"' >> #{file}\"")

  # TODO: remove duplicate keys
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
  setenv(params[:app], params[:key], params[:value])
end

get "/env/:app" do
  file = env_file(params[:app])

  host_exec("cat #{file}")
end

get "/id_rsa.pub" do
  content_type :txt

  public_key = `cat ~/.ssh/id_rsa.pub`

  if public_key == ""
    `scripts/gen_pub`

    public_key = `cat ~/.ssh/id_rsa.pub`
  end

  public_key
end

get "/set_ssh_keys" do
  setenv("manager", "PUBLIC_KEY", ENV["PUBLIC_KEY"])
  setenv("manager", "PRIVATE_KEY", ENV["PRIVATE_KEY"])
end

get "/deploy/:app" do
  DeployWorker.perform_async(params[:app])
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
