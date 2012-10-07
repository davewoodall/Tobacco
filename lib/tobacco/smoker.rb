module Tobacco
  class Smoker

    attr_accessor :consumer,
      :file_path_generator,
      :reader,
      :persister,
      :content

    def initialize(consumer, content = nil)
      self.consumer = consumer
      self.content  = content

      Tobacco::Callback.instance(consumer)
    end

    def generate_file_paths
      self.file_path_generator = Tobacco::Roller.new(consumer)
    end

    def read
      self.content = Tobacco::ContentReader.new(self).read
    end

    # Public: Writes content to file allowing for manipulation
    # of the content beforehand through the :before_write callback
    # This is due to the fact that content can be set directly
    # without going through the read method.
    #
    # Validate is only in the write method because
    # the content can be set directly and the read method
    # never called.
    #
    def write!
      Tobacco::ContentValidator.new(self).validate!
    end

    # Public: Called by ContentValidator if content is valid
    #
    def continue_write
      begin
        content_writer = Tobacco::Exhaler.new(content, filepath)
        content_writer.write!

        Tobacco::Callback.instance.notify(:on_success, content)

      rescue => e
        Tobacco.log("ErrorWriting: #{filepath}")

        error = error_object('Error Writing', e)
        Tobacco::Callback.instance.notify(:on_write_error, error)

        # raise
      end
    end

    #---------------------------------------------------------
    private

    def filepath
      @filepath ||= file_path_generator.output_filepath
    end

    def error_object(msg, e)
      Tobacco::Error.new(
        msg: msg,
        filepath: filepath,
        content: content,
        object: e
      )
    end

  end
end
