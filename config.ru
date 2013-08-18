require "./app"

require "sidekiq"
require 'sidekiq/web'

# Sidekiq::Web.use Rack::Auth::Basic do |username, password|
#   username == 'duder2' && password == ENV['SIDEKIQ_PASS']
# end

run Rack::URLMap.new(
  '/' => Sinatra::Application,
  '/sidekiq' => Sidekiq::Web
)
