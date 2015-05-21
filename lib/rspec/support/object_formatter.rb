module RSpec
  module Support
    # Provide additional output details beyond what `inspect` provides when
    # printing Time, DateTime, or BigDecimal
    module ObjectFormatter
      # @api private
      def self.format(object)
        if Time === object
          format_time(object)
        elsif defined?(DateTime) && DateTime === object
          format_date_time(object)
        elsif defined?(BigDecimal) && BigDecimal === object
          "#{object.to_s 'F'} (#{object.inspect})"
        elsif RSpec::Support.is_a_matcher?(object) && object.respond_to?(:description)
          object.description
        else
          object.inspect
        end
      end

      TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

      if Time.method_defined?(:nsec)
        # @private
        def self.format_time(time)
          time.strftime("#{TIME_FORMAT}.#{"%09d" % time.nsec} %z")
        end
      else # for 1.8.7
        # @private
        def self.format_time(time)
          time.strftime("#{TIME_FORMAT}.#{"%06d" % time.usec} %z")
        end
      end

      DATE_TIME_FORMAT = "%a, %d %b %Y %H:%M:%S.%N %z"
      # ActiveSupport sometimes overrides inspect. If `ActiveSupport` is
      # defined use a custom format string that includes more time precision.
      # @private
      def self.format_date_time(date_time)
        if defined?(ActiveSupport)
          date_time.strftime(DATE_TIME_FORMAT)
        else
          date_time.inspect
        end
      end
    end
  end
end
