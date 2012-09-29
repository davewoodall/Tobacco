module Tobacco
  class Roller

    def initialize(smoker)
      @smoker = smoker
    end

    def output_filepath
      @output_filepath ||= File.join(base_path, *filepath_options)
    end

    def content_url
      separator = url_path =~ /^\// ? '' : '/'

      @content_url ||= "#{host}#{separator}#{url_path}"
    end


    #---------------------------------------------------------
    private

    def url_path
      @url_path ||= @smoker.send(Tobacco.content_url_method)
    end

    def filepath_options
      @smoker.send(Tobacco.output_filepath_method)
    end

    def host
      Tobacco.published_host
    end

    def base_path
      Tobacco.base_path
    end
  end
end
