module Tobacco
  class Inhaler

    def initialize(url)
      @url = url
    end

    def fetch_content
      @smoke ||= Tobacco::Burnout.try(3) { URI.parse(@url).read }

    rescue OpenURI::HTTPError => e
      # @error_handler.call "Could not fetch content from url #{@url} -- Got '#{e}'"
    end

  end

end
