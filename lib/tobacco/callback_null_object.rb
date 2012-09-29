module Tobacco
  class CallbackNullObject
    def self.singleton
      @callback ||= new
    end

    def call(options)
      options
    end
  end
end

