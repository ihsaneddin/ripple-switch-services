source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.3'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'

# Use postgres as the database for Active Record
gem 'pg'
gem 'pg_search'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'remotipart'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
gem 'redis-namespace'
gem 'redis-rails'
gem 'redis-rack-cache'

# background processer server
gem 'sidekiq'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', :require => 'rack/cors'

# lightweight api stack GRAPE
gem 'grape', '0.19.1'
gem 'grape_on_rails_routes'
gem 'grape-entity'
gem 'grape-swagger'
gem 'kaminari-grape'
gem 'wine_bouncer'
gem 'grape-kaminari'
gem 'grape-cancan'

# pagination
gem 'kaminari'#, '~> 1.0'

# stateful models
gem 'aasm'

# friendly url id
gem 'friendly_id'#, '~> 5.0.0'

# file upload
gem 'carrierwave', '~> 0.5'
gem 'carrierwave_backgrounder', '~> 0.4.2'
gem 'mini_magick'
gem 'fog'

# soft delete support
gem "paranoia", "~> 2.2"

# PDF builder
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

# Ruby units converter
gem 'ruby-units'

#group :staging, :production do 
  # bugs and errors reports
  gem "sentry-raven"
#end

# for faster csv
gem 'fastest-csv'

# date validation
gem 'date_validator'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  #deployment
  gem 'capistrano', '~> 3.6', require: false
  gem 'capistrano-postgresql', '~> 4.2.0', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano3-nginx', require: false
  gem 'capistrano-upload-config', require: false
  gem 'capistrano-sidekiq', require: false
  
  # simple mail opener for development
  gem 'letter_opener'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "rails_best_practices"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# User management
gem 'devise'#,'~> 4.1'
gem 'cancancan'#, '~> 1.15'
gem 'rolify'#, '~> 1.2'
gem 'devise_token_auth' 
gem 'doorkeeper'
gem "rack-oauth2"#, "~> 1.0.5"
gem 'devise-two-factor'

# ripple rpc custom lib
gem 'ripple_lib_rpc_ruby', git: 'https://github.com/ihsaneddin/ripple-lib-rpc-ruby'

# serializer support
gem 'active_model_serializers', '~> 0.10.0'

gem 'rqrcode'

# ActiveRecord attr encryption support
gem 'attr_encrypted'

# websocket support
gem 'faye-websocket'

# api request throttling 
gem 'rack-defense'

# subscription payment
gem 'coinpayments'