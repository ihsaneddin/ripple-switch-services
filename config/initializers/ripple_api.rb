require 'ripple'

$rippleClient = Ripple.client(endpoint: ENV["RIPPLED_SERVER"] || 'http://127.0.0.1:5005/' )