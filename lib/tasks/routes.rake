namespace :api do
  desc "Grape api routes"
  task routes: :environment do
    Api::Base.routes.each do |api|
      method = api.request_method.ljust(10) if api.request_method
      path = api.path.gsub ":version", api.version if api.version
      puts "    #{method} #{path}"
    end
  end
end