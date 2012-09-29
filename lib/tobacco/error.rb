module Tobacco
  class Error
    attr_accessor :msg, :filepath, :content, :error

    def initialize(options = {})
      self.msg      = options[:msg]
      self.filepath = options[:filepath]
      self.content  = options[:content]
      self.error    = options[:error]
    end
  end
end
