set :application, 'rss-staging'
set :stage, :staging
set :rails_env, 'staging'

set :full_app_name, "#{fetch(:applicaton)}-#{fetch(:stage)}"
set :server_name, '139.59.107.166'#"api-staging.qashier.id"

set :deploy_to, '/home/deploy/rss'

# http://stackoverflow.com/questions/21036175/how-to-deploy-a-specific-revision-with-capistrano-3
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || 'master'

role :app, %w{deploy@139.59.107.166}
role :web, %w{deploy@139.59.107.166}
role :db,  %w{deploy@139.59.107.166}
server '139.59.107.166', user: 'deploy', roles: %w{web app}

# nginx conf
set :nginx_server_name, "139.59.107.166"

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }

set :puma_threads, [4, 16]
set :puma_workers, 5
#set :puma_worker_timeout, nil
#set :puma_init_active_record, false
#set :puma_preload_app, false
set :puma_daemonize, true

#
# sidekiq configurations
#

#set :sidekiq_default_hooks => true
#set :sidekiq_pid => File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid') # ensure this path exists in production before deploying.
#set :sidekiq_env => fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
#set :sidekiq_log => File.join(shared_path, 'log', 'sidekiq.log')
#set :sidekiq_options => nil
#set :sidekiq_require => nil
#set :sidekiq_tag => nil
#set :sidekiq_config => nil#"config/sidekiq.yml" # if you have a config/sidekiq.yml, do not forget to set this. 
#set :sidekiq_queue => nil
#set :sidekiq_timeout => 10
#set :sidekiq_role => :app
set :sidekiq_processes, 3
set :sidekiq_options_per_process, ["--queue transactions_subscriptions", "--queue notifications", "--queue critical --queue default --queue low --queue mailers"]
set :sidekiq_concurrency => 15#nil
#set :sidekiq_monit_templates_path => 'config/deploy/templates'
#set :sidekiq_monit_conf_dir => '/etc/monit/conf.d'
#set :sidekiq_monit_use_sudo, false
#set :monit_bin => '/usr/bin/monit'
#set :sidekiq_monit_default_hooks => true
#set :sidekiq_service_name => "sidekiq_#{fetch(:application)}_#{fetch(:sidekiq_env)}"
#set :sidekiq_cmd => "#{fetch(:bundle_cmd, "bundle")} exec sidekiq" # Only for capistrano2.5
#set :sidekiqctl_cmd => "#{fetch(:bundle_cmd, "bundle")} exec sidekiqctl" # Only for capistrano2.5
#set :sidekiq_user => "deploy" #user to run sidekiq as

set :pty,  false