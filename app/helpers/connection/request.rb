require 'hashie/mash'

module Connection
  class Request

    require 'net/http'

    attr_accessor :url, :port, :method, :response,  :uri, :net, :parser, :options, :http

    def initialize(method, url, options = {}, ssl=false, port=8080)
      @url = url
      @port = uri.port.nil?? port : uri.port
      @method = method.to_s
      @use_ssl = ssl
      @options = options.symbolize_keys
      @header = @options.delete(:header)
      @authentication = @options.delete(:authentication)
      @net = ::Net::HTTP
      @parser = ::JSON
    end

    def invoke
      begin
        @response = http.request(net_request)
      rescue => e
        puts e#.message
      end
    end

    def success?
      if @response.present?
       @response.kind_of? Net::HTTPSuccess
      end
    end

    def response
      if @response.present?
        return Hashie::Mash.new(parser.parse(@response.response.body))
      end
    end

    def status
      if @response.present?
        @response.status
      end
    end

    def header
      @header = @header.nil?? {'Content-Type' =>'application/json', "Accept" => "application/json"} : @header
    end

    def change_params new_params = {}
      @options[:params] = new_params unless new_params.blank?
    end

    def change_url new_url
      @url = new_url
    end

    def change_method new_method
      @method = new_method.to_s
    end

    protected

      def respond?
        @response.kind_of? Net::HTTPSuccess
      end
      
      def uri
        URI(url)
      end

      def http
        http = net.new uri.host, port
        http.use_ssl = use_ssl
        http
      end

      def net_http
        "::Net::HTTP::#{method.capitalize}".constantize
      end

      def net_request
        if method.to_sym == :get
          get_uri = uri
          get_uri.query = URI.encode_www_form( options[:params] ) if options[:params].present?
          request = net_http.new(get_uri, header)
        else
          request = net_http.new(uri, header)
          request["Authorization"] = authentication if @authentication
          request.body = options[:params].to_json if options[:params].present?
        end
        request
      end

      def use_ssl
        @use_ssl
      end

      def authentication
        if @authentication
          case @authentication[:type]
            when "HTTP Authentication Base64"
              return "Basic " + Base64::encode64("#{@authentication[:credential][:username]}:#{@authentication[:credential][:password]}").gsub("\n", "")
          end
        end
      end

      def ensure_params_has_keys resource_key, attributes_keys = []
        params = @options[:params]
        ensure_key_exists do
          return attributes_keys.all? { |key| params[resource_key.to_sym].key? key.to_sym }
        end
      end

      def ensure_key_exists
        begin
          raise "Block was not given" unless block_given?
          yield
        rescue => e
          puts "Some keys are missing"
        end
      end

  end
end