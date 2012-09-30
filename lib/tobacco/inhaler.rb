module Tobacco
  class Inhaler
    attr_accessor :url

    def initialize(url)
      self.url = url
    end

    def read
      @content ||= Tobacco::Burnout.try(3) { URI.parse(url).read }
    end
  end
end
