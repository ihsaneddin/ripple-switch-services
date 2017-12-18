require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RippleSwitchServices
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    envs = Rails.root.join("config", 'application.yml').to_s

    if File.exists?(envs)
      YAML.load_file(envs)[Rails.env].each do |key, value|
        ENV[key] = value
      end
    end

    #
    # autoload handlers modules
    #
    config.autoload_paths << "#{Rails.root}/lib/exception_handlers"

    #
    # change active record id field
    #
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    #
    # autoload grape api files
    #
    config.paths.add "app/services", glob: "**/*.rb"
    config.autoload_paths += Dir["#{Rails.root}/app/services/*"]

    #
    # request throttling
    #
    config.middleware.use Rack::Defense

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :sidekiq

  end
end
