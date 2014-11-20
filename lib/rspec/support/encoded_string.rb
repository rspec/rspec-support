module RSpec
  module Support
    # @private
    class EncodedString
      # Ruby's default replacement string for is U+FFFD ("\xEF\xBF\xBD") for Unicode encoding forms
      #   else is '?' ("\x3F")
      MRI_UNICODE_UNKOWN_CHARACTER = "\xEF\xBF\xBD"
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
          string.encode(@encoding)
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          normalize_missing(string.encode(@encoding, :invalid => :replace, :undef => :replace))
        rescue Encoding::ConverterNotFoundError
          normalize_missing(string.force_encoding(@encoding).encode(:invalid => :replace))
        end

        def normalize_missing(string)
          if @encoding.to_s == "UTF-8"
            string.gsub(MRI_UNICODE_UNKOWN_CHARACTER.force_encoding(@encoding), REPLACE)
          else
            string
          end
        end

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
