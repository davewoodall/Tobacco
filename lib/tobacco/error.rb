# Passed to callbacks when error occurs
#
# msg      #=> Context where the error occurred
# filepath #=> Filepath to where the file was to be written
# content  #=> Content to be written after it was modified using the callback before_write
# object   #=> The error object that raised the error
#
module Tobacco
  class Error
    attr_accessor :msg, :filepath, :content, :object

    def initialize(options = {})
      self.msg      = options[:msg]
      self.filepath = options[:filepath]
      self.content  = options[:content]
      self.object   = options[:object]
    end

    # Allow destructure of the error into variable names
    #
    # eg.
    #
    #   msg, filepath, content, object = *error
    #   [ 'Error writing file', '/path/to/file', '<h1>Title</h1>', #<Errno::EACCES: Permission denied - /users/index.txt> ]
    #
    # You can access the attributes normally as well
    #
    #   error.msg      #=> 'Error writing file'
    #   error.filepath #=> '/path/to/file'
    #   error.object   #=> #<Errno::EACCES: Permission denied - /users/index.txt>
    #
    def to_a
      [ msg, filepath, content, object ]
    end
    alias_method :to_ary, :to_a

  end
end
