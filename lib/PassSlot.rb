require "PassSlot/version"
require "PassSlot/engine"
require "PassSlot/errors"
require "PassSlot/objects"

module PassSlot

  class << self

    # @param [String] app_key PassSlot App Key
    # @param [String] base PassSlot API Endpoint
    # @param [String] version API Version
    # @param [Boolean] debug
    # @return [PassSlot::Engine]
    def start(app_key=nil, base='https://api.passslot.com', version='v1', debug=false)
      @engine = Engine.new(app_key, base, version, debug)
    end

  end

end
