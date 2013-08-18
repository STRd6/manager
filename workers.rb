require "sidekiq"

Dir[File.dirname(__FILE__) + '/workers/*.rb'].each do |file|
  require file
end
