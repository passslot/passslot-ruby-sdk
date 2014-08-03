require 'faraday'
require 'faraday_middleware'

module PassSlot
  class Engine

    attr_reader :app_key, :base_url, :debug

    # @param [String] app_key PassSlot App Key
    # @param [String] base PassSlot API Endpoint
    # @param [String] version API Version
    # @param [Boolean] debug
    # @return [PassSlot::Engine]
    def initialize(app_key=nil, base='https://api.passslot.com', version='v1', debug=false)
      @app_key = app_key || ENV['PASSSLOT_APPKEY']
      if @app_key.nil?
        raise "You must provide a PassSlot App Key. You can get your app key at https://www.passslot.com/account/apps"
      end

      @base_url = "#{base}/#{version}"
      @debug = debug
    end

    # @param [Integer] templateId Template Id
    # @param [Hash] values Placeholder values (placeholderName => placeholderValue)
    # @param [Hash] images Optional images (imageType => imagePath)
    # @return [PassSlot::Pass]
    # @raise [PassSlot::ApiError]
    def create_pass_from_template(templateId, values=nil, images=nil)
      resource = "templates/#{templateId}/pass"
      Pass.new(self, create_pass(resource, values, images))
    end

    # @param [String] templateName Template Name
    # @param [Hash] values Placeholder values (placeholderName => placeholderValue)
    # @param [Hash] images Optional images (imageType => imagePath)
    # @return [PassSlot::Pass]
    # @raise [PassSlot::ApiError]
    def create_pass_from_template_with_name(templateName, values=nil, images=nil)
      resource = "templates/names/#{URI::encode(templateName)}/pass" % (requests.compat.quote(templateName))
      Pass.new(self, create_pass(resource, values, images))
    end


    # @param [PassSlot::Pass] pass Existing Pass
    # @return [String] pkpass binary data
    # @raise [PassSlot::ApiError]
    def download_pass(pass)
      resource = "passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}"
      call :get, resource
    end

    # @param [PassSlot::Pass] pass Existing Pass
    # @return [Boolean] pkpass binary data
    # @raise [PassSlot::ApiError]
    def email_pass(pass, email)
      resource = "passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}/email"
      call :post, resource, email: email
      true
    end

    # @param [PassSlot::Pass] pass Existing Pass
    # @param [Hash] values Placeholder values (placeholderName => placeholderValue)
    # @return [Hash] New placeholder values
    # @raise [PassSlot::ApiError]
    def update_pass_values(pass, values)
      resource = "passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}/values"
      call :put, resource, values
    end

    # @param [PassSlot::Pass] pass Existing Pass
    # @param [String] placeholderName Name of the placeholder
    # @param [Object] value New placeholder value
    # @return [Hash] New placeholder values
    # @raise [PassSlot::ApiError]
    def update_pass_value(pass, placeholderName, value)
      resource = "passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}/values/#{placeholderName}"
      call :put, resource, value: value
    end

    protected

    ALLOWED_IMAGES = ['icon', 'logo', 'strip', 'thumbnail', 'background', 'footer'] unless defined? ALLOWED_IMAGES
    MULTIPART_BOUNDARY = "-----------PassSlotRubyMultipartPost".freeze unless defined? MULTIPART_BOUNDARY
    APPLICATION_JSON = 'application/json'.freeze unless defined? APPLICATION_JSON
    CONTENT_TYPE = 'Content-Type'.freeze unless defined? CONTENT_TYPE
    DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + '../data/cacert.pem' unless defined? DEFAULT_CA_BUNDLE_PATH

    def create_pass(resource, values, images)
      multipart = !images.nil? && !images.empty?

      if multipart

        parts = []
        images.each do |type, image|
          if ALLOWED_IMAGES.include?(type.to_s) || ALLOWED_IMAGES.include?(type.to_s.chomp('2x'))
            # Wrap UploadIO in Mime Part because we need to craft the multipart message ourselves
            parts << Faraday::Parts::Part.new(MULTIPART_BOUNDARY, type, Faraday::UploadIO.new(image, 'image/png'))
          else
            warn "Image type #{type} not available. Image will be ignored."
          end
        end

        json = FaradayMiddleware::EncodeJson.new.encode(values)
        parts << Faraday::Parts::ParamPart.new(MULTIPART_BOUNDARY, "values", json, {CONTENT_TYPE => APPLICATION_JSON})

        content = parts
      else
        content = values
      end

      call :post, resource, content, multipart
    end

    def call(method, resource, content=nil, multipart=false)

      @connection = Faraday.new(ssl: {ca_path: DEFAULT_CA_BUNDLE_PATH}) do |conn|
        conn.url_prefix = @base_url

        conn.request :json

        conn.response :json, :content_type => APPLICATION_JSON
        conn.response :logger if @debug

        conn.adapter Faraday.default_adapter
      end unless defined? @connection

      headers = {
          'User-Agent' => "PassSlotSDK-Ruby/#{VERSION}",
          'Accept' => APPLICATION_JSON,
          'Authorization' => @app_key,
      }

      if multipart
        # Code adapted from faraday multipart middleware, we need to do this ourselves because
        # the middleware does not allow to specify the content type for the json part
        content << Faraday::Parts::EpiloguePart.new(MULTIPART_BOUNDARY)
        content = Faraday::CompositeReadIO.new(content)

        headers[CONTENT_TYPE] = "multipart/form-data; boundary=#{MULTIPART_BOUNDARY}"
        headers[Faraday::Env::ContentLength] = content.length.to_s
      end

      response = @connection.run_request(method, resource, content, headers)

      if response.status == 422
        raise ValidationError.new(response.body)
      end

      if response.status == 401
        raise UnauthorizedError.new
      end

      if !response.success?
        raise ApiError.new(response.status, response.body)
      end

      response.body
    end
  end
end