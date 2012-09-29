module Tobacco
  class Exhaler

    def initialize(content, filepath)
      @content, @filepath = content, filepath
    end

    def write!
     create_directory
     write_content_to_file
    end

    def create_directory
      Tobacco.log("Creating directory: #{File.dirname(@filepath)}")
      FileUtils.mkdir_p( File.dirname(@filepath) )
    end

    def write_content_to_file
      File.open(@filepath, 'w') do |f|
        f.write @content
      end
    end

  end
end
