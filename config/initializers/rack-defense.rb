
Rack::Defense.setup do |config|
  #config.throttle('api', 1, 1.hour.in_milliseconds) do |req|
  #  req.env['warden'].user.id if (%r{^/api/} =~ req.path) && req.env['warden'].user
  #end

  Users::Models::Plan.cached_collection.each do |plan|
    next if (plan.max_api_request_per_second <= 0) rescue false
    config.throttle('api', plan.features[:max_api_request_per_second], 1.second.in_milliseconds) do |req|
      req.env['warden'].user.id if (%r{^/api/} =~ req.path) &&  req.env['warden'].user.present? &&(req.env['warden'].user.active_plan.name == plan.name)
    end
  end

  config.banned_response =
    ->(env) { [404, {'Content-Type' => 'application/json'}, [{message: "Not found"}.to_json]] }
  config.throttled_response =
    ->(env) { [503, {'Content-Type' => 'application/json'}, [{message: "Maximum request per second has been reached. Try again later."}.to_json]] }

end