module RSpec
  module Support
    # @private
    class EncodedString
      # Ruby's default replacement string for is U+FFFD ("\xEF\xBF\xBD") for Unicode encoding forms
      #   else is '?' ("\x3F")
      REPLACE = "\x3F"

      def initialize(string, encoding=nil)
        @encoding = encoding
        @source_encoding = detect_source_encoding(string)
        @string = matching_encoding(string)
      end
      attr_reader :source_encoding

      delegated_methods = String.instance_methods.map(&:to_s) & %w[eql? lines == encoding empty?]
      delegated_methods.each do |name|
        define_method(name) { |*args, &block| @string.__send__(name, *args, &block) }
      end

      def <<(string)
        @string << matching_encoding(string)
      end

      def split(regex_or_string)
        @string.split(matching_encoding(regex_or_string))
      end

      def to_s
        @string
      end
      alias :to_str :to_s

      if String.method_defined?(:encoding)

        private

        ENCODING_STRATEGY = {
          :bad_bytes => {
            :invalid => :replace,
            # :undef   => :nil,
            :replace => REPLACE
          },
          :cannot_convert => {
            # :invalid => :nil,
            :undef   => :replace,
            :replace => REPLACE
          },
          :no_converter => {
            :invalid => :replace,
            # :undef   => :nil,
            :replace => REPLACE
          }
        }

        # Raised by Encoding and String methods:
        #   Encoding::UndefinedConversionError:
        #     when a transcoding operation fails
        #     e.g. "\x80".encode('utf-8','ASCII-8BIT')
        #   Encoding::InvalidByteSequenceError:
        #     when the string being transcoded contains a byte invalid for the either
        #     the source or target encoding
        #     e.g. "\x80".encode('utf-8','US-ASCII')
        # Raised by transcoding methods:
        #   Encoding::ConverterNotFoundError:
        #     when a named encoding does not correspond with a known converter
        #     e.g. 'abc'.force_encoding('utf-8').encode('foo')
        # Encoding::CompatibilityError
        #
        def matching_encoding(string)
          # Converting it to a higher character set (UTF-16) and then back (to UTF-8)
          # ensures that we strip away invalid or undefined byte sequences
          # => no need to rescue Encoding::InvalidByteSequenceError, ArgumentError
          string.encode(::Encoding::UTF_16LE, ENCODING_STRATEGY[:bad_bytes]).
            encode(@encoding)
        rescue Encoding::UndefinedConversionError, Encoding::CompatibilityError
          string.encode(@encoding, ENCODING_STRATEGY[:cannot_convert])
        # Begin: Needed for 1.9.2
        rescue Encoding::ConverterNotFoundError
          string.force_encoding(@encoding).encode(ENCODING_STRATEGY[:no_converter])
        end
        # End: Needed for 1.9.2


        def detect_source_encoding(string)
          string.encoding
        end
      else

        private

        def matching_encoding(string)
          string
        end

        def detect_source_encoding(_string)
          'US-ASCII'
        end
      end
    end
  end
end
