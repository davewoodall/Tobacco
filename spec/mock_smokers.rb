
module Writers
  class Banner
    def self.perform(options)
      writer = new(options)
      writer.write!
    end

    def initialize(options)
      @options = options
    end

    def content_url
      "/protosite_publisher/mobile_homepage"
    end

    def output_filepath
      [ '1', "mobile_banners.xml" ]
    end

  end
end
