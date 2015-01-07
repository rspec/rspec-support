module RSpec
  module Support
    module EncodingHelpers
      module_function

      if String.method_defined?(:encoding)

        def expect_identical_string(str1, str2, expected_encoding=str1.encoding)
          expect(str1.encoding).to eq(expected_encoding)
          expect(str1.each_byte.to_a).to eq(str2.each_byte.to_a)
        end

      else

        def expect_identical_string(str1, str2, _expected_encoding=nil)
          expect(str1.split(//)).to eq(str2.split(//))
        end
      end
    end
  end
end
