module RSpec
  module Support
    # @private
    class EncodedString
      # Reduce allocations by storing constants.
      UTF_8 = "UTF-8"
      US_ASCII = 'US-ASCII'
      #  else: '?' 63.chr ("\x3F")
      REPLACE = "?"
      ENCODE_UNCONVERTABLE_BYTES =  {
        :invalid => :replace,
        :undef   => :replace
      }
      ENCODE_NO_CONVERTER = {
        :invalid => :replace,
      }

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

        # Encoding Exceptions:
        #
        # Raised by Encoding and String methods:
        #   Encoding::UndefinedConversionError:
        #     when a transcoding operation fails
        #     if the String contains characters invalid for the target encoding
        #     e.g. "\x80".encode('UTF-8','ASCII-8BIT')
        #     vs "\x80".encode('UTF-8','ASCII-8BIT', undef: :replace, replace: '<undef>')
        #     # => '<undef>'
        #   Encoding::CompatibilityError
        #    when Enconding.compatbile?(str1, str2) is false
        #     e.g. utf_16le_emoji_string.split("\n")
        #     e.g. valid_unicode_string.encode(utf8_encoding) << ascii_string
        #   Encoding::InvalidByteSequenceError:
        #     when the string being transcoded contains a byte invalid for
        #     either the source or target encoding
        #     e.g. "\x80".encode('UTF-8','US-ASCII')
        #     vs "\x80".encode('UTF-8','US-ASCII', invalid: :replace, replace: '<byte>')
        #     # => '<byte>'
        #   ArgumentError
        #    when operating on a string with invalid bytes
        #     e.g."\xEF".split("\n")
        #   TypeError
        #    when a symbol is passed as an encoding
        #    Encoding.find(:"utf-8")
        #    when calling force_encoding on an object
        #    that doesn't respond to #to_str
        #
        # Raised by transcoding methods:
        #   Encoding::ConverterNotFoundError:
        #     when a named encoding does not correspond with a known converter
        #     e.g. 'abc'.force_encoding('UTF-8').encode('foo')
        #     or a converter path cannot be found
        #     e.g. "\x80".force_encoding('ASCII-8BIT').encode('Emacs-Mule')
        #
        # Raised by byte <-> char conversions
        #  RangeError: out of char range
        #   e.g. the UTF-16LE emoji: 128169.chr
        def matching_encoding(string)
          string.encode(@encoding)
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          normalize_missing(string.encode(@encoding, ENCODE_UNCONVERTABLE_BYTES))
        rescue Encoding::ConverterNotFoundError
          normalize_missing(string.dup.force_encoding(@encoding).encode(ENCODE_NO_CONVERTER))
        end

        # Ruby's default replacement string is:
        # for Unicode encoding forms: U+FFFD ("\xEF\xBF\xBD")
        MRI_UNICODE_UNKOWN_CHARACTER = "\xEF\xBF\xBD".force_encoding(UTF_8)

        def normalize_missing(string)
          if @encoding.to_s == UTF_8
            string.gsub(MRI_UNICODE_UNKOWN_CHARACTER, REPLACE)
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
          US_ASCII
        end
      end
    end
  end
end
