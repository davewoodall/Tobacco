module Tobacco
  module Burnout

    class MaximumAttemptsExceeded < Exception; end

    def self.try(max_attempts, &block)
      attempts = 1

      while(attempts <= max_attempts)
        success, return_value = attempt &block
        return return_value if success

        attempts += 1
      end

      raise MaximumAttemptsExceeded.new("Execution timed out more than #{max_attempts} time(s).  I give up.")
    end

    def self.attempt(&block)
      begin
        [ true, yield ]
      rescue
        false
      end
    end

  end
end
