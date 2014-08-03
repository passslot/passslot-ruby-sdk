require 'ostruct'

module PassSlot
  class Object < OpenStruct

    attr_reader :engine

    def initialize(engine, json)
      @engine = engine
      super json
    end

  end


  # @attr [String] serialNumber
  # @attr [String] passTypeIdentifier
  # @attr [String] url URL of the pass intended for user
  class Pass < Object

    # @return [Object] pkpass binary data
    # @raise [PassSlot::ApiError]
    def download!
      @data = @engine.download_pass(self)
    end

    # @param [String] to Email address
    # @return [Boolean] Success
    # @raise [PassSlot::ApiError]
    def email!(to)
      @engine.email_pass(self, to)
    end

    # @raise [PassSlot::ApiError]
    # @param [Hash,String] placeholderOrValues Single placeholder name to update or Hash of all placeholder values to update
    # @param [Object] value Value of single placeholder to update
    # @return [Hash] New placeholder values
    def update!(placeholderOrValues, value=nil)
      if placeholderOrValues.is_a? Hash
        @values = @engine.update_pass_values(self, placeholderOrValues)
      else
        @values = @engine.update_pass_value(self, placeholderOrValues, value)
      end
    end

  end

end