module Tobacco
  class MissingContentError < RuntimeError
    def message
      "No error encountered but content is empty"
    end
  end

  class ContentValidator
    attr_accessor :content

    def initialize(smoker)
      @smoker      = smoker
      self.content = smoker.content
    end

    # Public: Verifies that content is present and calls
    #         continue_write on the Smoker class if so
    #         and notifies the consumer class of the
    #         read error if not
    #
    def validate!
      if content_present?
        @smoker.continue_write
      else

        # ????? IS this still true
        #
        # At this point, the content might be an error object
        # but if not, we create one
        #
        object = missing_content_error(content)
        error  = error_object('Error Reading', object)

        Tobacco::Callback.instance.notify(:on_read_error, error)
      end
    end

    #---------------------------------------------------------
    private

    def content_present?
      @content_present ||= content?
    end

    def content?
      return false if content.nil? || content.empty?

      Array(content).last !~ /404 Not Found|The page you were looking for doesn't exist/
    end

    # Private: Convenience method to create a Tobacco::Error object
    #
    # msg              - Context where the error occurred
    # modified_content - Content after the :before_write callback
    # e                - The error that was raised
    #
    def error_object(msg, e)
      Tobacco::Error.new(
        msg: msg,
        filepath: @smoker.filepath,
        content: content,
        object: e
      )
    end

    # Private: Creates an error object if content is a string or nil
    #
    # content - A string, nil or Error object
    # 
    # returns an Error object
    #
    def missing_content_error(content)
      if content.respond_to? :message
        content
      else
        Tobacco::MissingContentError.new
      end
    end

  end
end
