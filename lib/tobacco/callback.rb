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

    # Public: Notify the writer class based on callback name
    #         passing along data which is either content or
    #         an error object
    #
    # name - symbol - the callback name
    #
    # data - text or object
    #
    # return - data
    #
    def notify(name, data)
      if writer.respond_to? name
        writer.send(name, data)
      else
        data
      end
    end
  end
end
