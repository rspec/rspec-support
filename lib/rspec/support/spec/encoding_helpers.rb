module RSpec
  module Support
    module EncodingHelpers
      module_function
      if String.method_defined?(:encoding)

        def expect_identical_string(str1, str2, expected_encoding=str1.encoding)
          str1.encoding == expected_encoding &&
            str1.each_byte.to_a == str2.each_byte.to_a
        end

      else

        def expect_identical_string(str1, str2)
          str1.split(//) == str2.split(//)
        end
      end
    end
  end
end
require 'rspec/expectations'
# Special matchers for comparing encoded strings so that
# we don't run any expectation failures through the Differ,
# which also relies on EncodedString. Instead, confirm the
# strings have the same encoding and same bytes.
RSpec::Matchers.define :be_identical_string do |expected|
  match do |actual|
    RSpec::Support::EncodingHelpers.expect_identical_string(actual, expected)
  end
end
