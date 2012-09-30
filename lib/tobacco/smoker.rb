module Tobacco
  class Smoker

    attr_accessor :smoker,
      :file_path_generator,
      :reader,
      :writer

    def initialize(smoker)
      self.smoker = smoker
      @content    = nil
    end

    def generate_file_paths
      self.file_path_generator = Roller.new(smoker)
    end

    def read
      self.reader = choose_reader
      @content    = reader.send(Tobacco.content_method)

      unless content_present?
        error = error_object('Error Reading', '', @content)
        callback(:on_read_error, )
      end
    end

    def write!
      return unless content_present?

      begin
        filepath         = file_path_generator.output_filepath
        modified_content = modify_content_before_writing
        content_writer   = Tobacco::Exhaler.new(modified_content, filepath)

        content_writer.write!

        callback(:on_success, modified_content)

      rescue => e

        error = error_object('Error Writing', modified_content, e)
        callback(:on_write_error, error)
      end
    end

    #---------------------------------------------------------
    private

    def error_object(msg, modified_content, e)
      Tobacco::Error.new(
        msg: msg,
        filepath: file_path_generator.filepath,
        content: modified_content,
        object: e
      )
    end

    def modify_content_before_writing
      callback(:before_write, @content)
    end

    def content_present?
      @content_present ||= content?
    end

    def content?
      return false if @content.nil? || @content.empty?

      Array(@content).last !~ /404 Not Found|The page you were looking for doesn't exist/
    end

    def choose_reader
      if smoker.respond_to? Tobacco.content_method
        smoker
      else
        Inhaler.new(file_path_generator.content_url).tap do |inhaler|

          # Add an alias for the user configured content_method
          # so that when it is called it calls fetch_content
          # on the Inhaler instance
          #
          inhaler.instance_eval %{
            alias :"#{Tobacco.content_method}" :read
          }
        end
      end
    end

    def callback(name, *args)
      if smoker.respond_to? name
        smoker.send(name, args)
      end
    end
  end
end
