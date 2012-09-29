module Tobacco
  class CallbackNotSupportedError < RuntimeError; end

  class Smoker

    ALLOWED_CALLBACKS = [ :on_success, :before_write, :on_read_error, :on_write_error ]

    attr_accessor :smoker,
      :file_path_generator,
      :reader,
      :writer

    def initialize(smoker)
      self.smoker = smoker
      @content    = nil
      @callbacks  = {}

      init_callbacks
    end

    def generate_file_paths
      self.file_path_generator = Roller.new(smoker)
    end

    def read
      self.reader = choose_reader
      @content    = reader.send(Tobacco.content_method)

      smoker.send(@callbacks[:on_read_error], 'Error reading content') unless content_present?
    end

    def write!
      return unless content_present?

      begin
        filepath         = file_path_generator.output_filepath
        modified_content = modify_content_before_writing
        content_writer   = Tobacco::Exhaler.new(modified_content, filepath)

        content_writer.write!

        smoker.send(@callbacks[:on_success], modified_content)

      rescue Errno::ENOENT => e

        error = Tobacco::Error.new(
          msg: "Error writing: #{filepath}",
          filepath: filepath,
          content: modified_content,
          error: e
        )

        smoker.send(@callbacks[:on_write_error], error)
      end
    end

    def add_callback(name, method_name)
      name = name.to_sym
      raise_unless_callbacks_include(name)

      @callbacks[name] = method_name
    end


    #---------------------------------------------------------
    private

    def modify_content_before_writing
      smoker.send(@callbacks[:before_write], @content)
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
            alias :"#{Tobacco.content_method}" :fetch_content
          }
        end
      end
    end

    def init_callbacks
      ALLOWED_CALLBACKS.each do |name|
        @callbacks[name] = CallbackNullObject.singleton
      end
    end

    def raise_unless_callbacks_include(name)
      unless ALLOWED_CALLBACKS.include?(name)
        raise Tobacco::CallbackNotSupportedError, "Tobacco supports the following callbacks: #{Tobacco.allowed_callbacks}"
      end
    end

    def self.allowed_callbacks
      ALLOWED_CALLBACKS.join(', ')
    end
  end
end
