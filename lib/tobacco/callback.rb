module Tobacco
  class Callback
    attr_accessor :writer

    def self.instance(writer = nil)
      @instance ||= new(writer)
    end
    private_class_method :new

    def initialize(writer = nil)
      self.writer = writer
    end

    def notify(name, data)
      if writer.respond_to? name
        writer.send(name, data)
      else
        data
      end
    end
  end
end
