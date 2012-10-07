module Tobacco
  class ContentReader
    attr_accessor :reader, :content, :modified_content

    def initialize(smoker)
      @smoker   = smoker
      @consumer = smoker.consumer
      @filepath = smoker.file_path_generator
    end

    def read
      choose_reader
      read_content
      modify_content
    end

    def modify_content
      self.modified_content = \
        Tobacco::Callback.instance.notify(:before_write, content)
    end

    def read_content
      self.content = reader.send(Tobacco.content_method)
    end

    # The reader will either be the calling class (consumer)
    # if it provides the content method or a new Inhaler
    # object that will be used to read the content from a url
    #
    def choose_reader
      self.reader = \
        if @consumer.respond_to? Tobacco.content_method
          @consumer
        else
          Inhaler.new(@filepath.content_url).tap do |inhaler|

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
  end
end
