module HTTP
  Error = Class.new(StandardError) # Better to classify network errors separately

  module_function

  DEFAULT_OPTION = { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER }.freeze
  DEFAULT_HEADER = {}.freeze

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def post(data:, endpoint:, option: {}, header: {})
    uri = URI.parse(endpoint)

    http = Net::HTTP.new(uri.host, uri.port).tap do |this|
      DEFAULT_OPTION.merge(option).each { |key, value| this.public_send("#{key}=", value) }
    end

    request      = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER.merge(header))
    request.body = data.to_s

    begin
      http.request(request)
    rescue StandardError => e # Why? See https://stackoverflow.com/a/11802674
      raise Error, "Error on posting: #{e.message}"
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
