module RSpec
  module Support
    # Provide additional output details beyond what `inspect` provides when
    # printing Time, DateTime, or BigDecimal
    module ObjectInspector
      DEFAULT_OPTIONS = {
        :nested => false,
        :joiner => ',',
        :braces => true,
        :trailing_comma => false
      }
      # @api private
      # rubocop:disable CyclomaticComplexity
      # rubocop:disable MethodLength
      def self.inspect(object, options=DEFAULT_OPTIONS)
        case object
        when Time
          format_time(object)
        when Hash
          format_hash(object, options)
        else
          if defined?(DateTime) && DateTime === object
            format_date_time(object)
          elsif defined?(BigDecimal) && BigDecimal === object
            "#{object.to_s 'F'} (#{object.inspect})"
          elsif RSpec::Support.is_a_matcher?(object) && object.respond_to?(:description)
            object.description
          else
            registered_klasses.each do |klass, inspector|
              return inspector.call(object) if klass === object
            end
            object.inspect
          end
        end
      end
      # rubocop:enable CyclomaticComplexity
      # rubocop:enable MethodLength

      # @private
      def self.format_hash(object, options)
        nested_options = { :braces => true, :joiner => ', ' }

        pairs = object.sort_by { |k, _| k.to_s }.map do |key, value|
          "#{inspect(key, nested_options)} => #{inspect(value, nested_options)}"
        end

        results = pairs.join(options[:joiner])
        results = "{#{results}}" if options[:braces]
        results += ',' if options[:trailing_comma]
        results
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

      def self.register(klass, &block)
        registered_klasses[klass] = block
      end

      def self.registered_klasses
        @registered_klasses ||= {}
      end
    end
  end
end
