module SpreeOxygenPelatologio
  class Client
    include Spree::IntegrationsConcern

    SERVICE_ENDPOINTS = {
      sandbox: 'https://sandbox.api.oxygen.gr/v1/',
      production: 'https://api.oxygen.gr/v1/'
    }.freeze

    attr_reader :client

    def initialize
      @integration = store_integration('oxygen_pelatologio')
      raise 'Integration not found' unless @integration

      validate!
    end

    def call(action, **kwargs, &block)
      case action
      when :pull_products
        pull_products(**kwargs, &block)
      else
        raise ArgumentError, "Unknown action: #{action}"
      end
    end

    private

    def validate!
      if @integration.preferred_api_key.to_s.strip.empty?
        raise ConfigurationError, "Oxygen api_key is not configured"
      end
    end

    def pull_products(per_page: 100, &block)
      return enum_for(:pull_products, per_page: per_page) unless block_given?

      params = {
        per_page: per_page,
        page: 1
      }

      loop do
        result = get('products', params: params)

        yield(result['data'])

        next_link = result.dig('links', 'next')
        break if next_link.nil?

        params[:page] += 1
      end
    end

    def get(path, params: {})
      uri = build_uri(path, params)

      request = Net::HTTP::Get.new(uri)
      apply_headers(request)

      perform_request(uri, request)
    end

    def build_uri(path, params)
      base_url = SERVICE_ENDPOINTS[@integration.preferred_environment.to_sym]
      uri = URI.join(base_url, path)

      if params.any?
        uri.query = URI.encode_www_form(params.compact)
      end

      uri
    end

    def apply_headers(request)
      request["Accept"] = "application/json"
      request["User-Agent"] = "SpreeOxygenPelatologio/#{SpreeOxygenPelatologio::VERSION}"

      api_key = @integration.preferred_api_key.to_s.strip
      request["Authorization"] = "Bearer #{api_key}"
    end

    def perform_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise ApiError, "Oxygen API error: #{response.code} #{response.message}"
      end

      parse_json(response.body)
    rescue Timeout::Error, Errno::ECONNREFUSED, SocketError => e
      raise ApiError, "Oxygen API connection error: #{e.message}"
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError => e
      raise ApiError ,"Invalid JSON from Oxygen: #{e.message}"
    end

    class ConfigurationError < StandardError; end
    class ApiError < StandardError; end
  end
end
