module RSpec
  module Support
    module EncodingHelpers
      module_function

      # For undefined conversions, replace as "U+<codepoint>"
      # e.g. '\xa0' becomes 'U+00A0'
      # see https://github.com/ruby/ruby/blob/34fbf57aaa/test/ruby/test_transcode.rb#L2050
      def safe_chr
        # rubocop:disable Style/RescueModifier
        @safe_chr ||= Hash.new { |h, x| h[x] = x.chr rescue ("U+%.4X" % [x]) }
        # rubocop:enable Style/RescueModifier
      end

      if String.method_defined?(:encoding)

        def safe_codepoints(str)
          str.each_codepoint.map { |codepoint| safe_chr[codepoint] }
        rescue ArgumentError
          str.each_byte.map { |byte| safe_chr[byte] }
        end

        # rubocop:disable MethodLength
        def expect_identical_string(str1, str2, expected_encoding=str1.encoding)
          expect(str1.encoding).to eq(expected_encoding)
          str1_bytes = safe_codepoints(str1)
          str2_bytes = safe_codepoints(str2)
          return unless str1_bytes != str2_bytes
          str1_differences = []
          str2_differences = []
          # rubocop:disable Style/Next
          str2_bytes.each_with_index do |str2_byte, index|
            str1_byte = str1_bytes.fetch(index) do
              str2_differences.concat str2_bytes[index..-1]
              return
            end
            if str1_byte != str2_byte
              str1_differences << str1_byte
              str2_differences << str2_byte
            end
          end
          # rubocop:enable Style/Next
          expect(str1_differences.join).to eq(str2_differences.join)
        end
        # rubocop:enable Style/MethodLength

      else

        def safe_codepoints(str)
          str.split(//)
        end

        def expect_identical_string(str1, str2)
          str1_bytes = safe_codepoints(str1)
          str2_bytes = safe_codepoints(str2)
          expect(str1_bytes).to eq(str2_bytes)
        end
      end
    end
  end
end
