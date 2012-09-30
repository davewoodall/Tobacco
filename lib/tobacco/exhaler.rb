module Tobacco
  class Exhaler
    attr_accessor :content, :filepath

    def initialize(content = '', filepath = '')
      self.content = content
      self.filepath = filepath
    end

    def write!
     create_directory
     write_content_to_file
    end

    def create_directory
      FileUtils.mkdir_p File.dirname(filepath)
    end

    def write_content_to_file
      File.open(filepath, 'w') do |f|
        f.write content
      end
    end

  end
end
