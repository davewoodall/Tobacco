module Tobacco
  class MissingContentError < RuntimeError
    def message
      "No error encountered but content is empty"
    end
  end

  class Smoker

    attr_accessor :smoker,
      :file_path_generator,
      :reader,
      :writer,
      :content

    def initialize(smoker, content = '')
      self.smoker  = smoker
      self.content = content
    end

    def generate_file_paths
      self.file_path_generator = Roller.new(smoker)
    end

    def read
      choose_reader
      read_content
      verify_content
    end

    def write!
      return unless content_present?

      begin
        filepath         = file_path_generator.output_filepath
        modified_content = modify_content_before_writing
        content_writer   = Tobacco::Exhaler.new(modified_content || content, filepath)

        content_writer.write!

        callback(:on_success, modified_content)

      rescue => e
        Tobacco.log("ErrorWriting: #{filepath}")

        # Remove the empty file
        File.delete(filepath) if File.exists?(filepath)

        error = error_object('Error Writing', modified_content, e)
        callback(:on_write_error, error)
      end
    end


    #---------------------------------------------------------
    # End of Public API
    #---------------------------------------------------------


    #---------------------------------------------------------
    # Write helper methods
    #---------------------------------------------------------
    def modify_content_before_writing
      callback(:before_write, content)
    end

    #---------------------------------------------------------
    # Read helper methods
    #---------------------------------------------------------
    def read_content
      self.content = reader.send(Tobacco.content_method)
    end

    def verify_content
      unless content_present?

        # At this point, the content might be an error object
        # but if not, we create one
        #
        object = missing_content_error(content)
        error  = error_object('Error Reading', '', object)

        callback(:on_read_error, error)
      end
    end

    def missing_content_error(content)
      if content.respond_to? :message
        content
      else
        Tobacco::MissingContentError.new
      end
    end

    def content_present?
      @content_present ||= content?
    end

    def content?
      return false if content.nil? || content.empty?

      Array(content).last !~ /404 Not Found|The page you were looking for doesn't exist/
    end

    def choose_reader
      # The reader will either be the calling class (smoker)
      # if it provides the content method or a new Inhaler
      # object that will be used to read the content from a url
      #
      self.reader = \
        if smoker.respond_to? Tobacco.content_method
          smoker
        else
          Inhaler.new(file_path_generator.content_url).tap do |inhaler|

            # Add an alias for the user configured content_method
            # so that when it is called it calls :read
            # on the Inhaler instance
            #
            inhaler.instance_eval %{
              alias :"#{Tobacco.content_method}" :read
            }
          end
      end
    end

    #---------------------------------------------------------
    # private

    def error_object(msg, modified_content, e)
      Tobacco::Error.new(
        msg: msg,
        filepath: file_path_generator.output_filepath,
        content: modified_content,
        object: e
      )
    end

    def callback(name, error)
      if smoker.respond_to? name
        smoker.send(name, error)
      end
    end
  end
end
