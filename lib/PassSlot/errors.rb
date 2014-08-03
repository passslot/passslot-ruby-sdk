module PassSlot

  class ApiError < StandardError

    attr_reader :status

    def initialize(status, response)
      @status = status
      super "[#{status}]: #{response}"
    end

  end

  class ValidationError < ApiError

    def initialize(response)

      msg = ''
      if response && response['message']
        msg = response['message']
        response['errors'].each do |error|
          msg += "; #{error['field']}: #{error['reasons'].join(', ')}"
        end
      end

      super 422, msg
    end

  end

  class UnauthorizedError < ApiError

    def initialize
      super 401, 'Unauthorized. Please check your app key and make sure it has access to the template and pass type id'
    end

  end


end