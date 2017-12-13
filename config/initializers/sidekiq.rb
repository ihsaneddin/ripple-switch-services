require 'sidekiq'
require 'sidekiq/web'

ENV['REDIS_SERVER'] ||= 'redis://localhost:6379/'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  if Rails.env.development?
    [user, password] == ['admin', 'password']
  else
    [user, password] == [ENV['SIDEKIQ_WEB_NAME'], ENV['SIDEKIQ_WEB_PASS']]
  end
end

Sidekiq.configure_server do |config|
  config.redis = { 
                    url: ENV['REDIS_SERVER'],
                    #size: 12,
                    namespace: "#{ Rails.env }_rss" 
                  }
  # config.poll_interval = 5
  config.average_scheduled_poll_interval = 5

  #database_url = ENV['DATABASE_URL']
  #if database_url
  #  ENV['DATABASE_URL'] = "#{ database_url }?pool=25"
  #  ActiveRecord::Base.establish_connection
  #end

  config.on(:startup) do
    puts 'Worker starting up!'
  end
  config.on(:quiet) do
    puts 'Worker is quiet!'
  end
  config.on(:shutdown) do
    puts 'Worker shutting down!'
  end
end

Sidekiq.configure_client do |config|
  config.redis = { 
                    url: ENV['REDIS_SERVER'],
                    #size: 1,
                    namespace: "#{ Rails.env }_rss" 
                 }
end



Sidekiq::Extensions.enable_delay!