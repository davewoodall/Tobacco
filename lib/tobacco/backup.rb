require 'tempfile'

module Tobacco
  class Backup
    attr_reader :file

    def initialize(filepath, content)
      @filepath = filepath
      @content  = content
      @file     = tempfile

      open
    end

    def tempfile
      Tempfile.new( File.basename(@filepath) )
    end

    def open
      @file.write @content
      @file.rewind
    end

    def read
      @file.read
    end

    def close
      @file.close
      @file.unlink
    end

  end
end
