module RSpec
  module Support
    # Provides a means to fuzzy-match between two arbitrary objects.
    # Understands array/hash nesting. Uses `===` or `==` to
    # perform the matching.
    class FuzzyMatcher
      def initialize(expected, actual)
        @failure_path, @raw_failure_message = failure_path_and_message(expected, actual) || []
        @failure_message =
          if @raw_failure_message
            inspected_path = "#{actual.inspect}#{@failure_path}"
            if @raw_failure_message.empty?
              "#{inspected_path} failed to match"
            else
              "#{inspected_path} failed to match: #{@raw_failure_message}"
            end
          end
      end

      def matched?
        !@failure_message
      end
      attr_reader :failure_message

    protected

      attr_reader :raw_failure_message, :failure_path

    private

      # @return [<String, String>, nil]
      def failure_path_and_message(expected, actual)
        if Hash === actual
          return hash_failure_path_and_message(expected, actual) if Hash === expected
        elsif Array === expected && Enumerable === actual && !(Struct === actual)
          return array_failure_path_and_message(expected, actual.to_a)
        end

        return if expected == actual || _eql?(expected, actual)

        failure_message = expected.respond_to?(:failure_message) && expected.failure_message

        return '', failure_message || "expected #{actual.inspect} to match #{expected.inspect}"
      end

      def _eql?(expected, actual)
        expected === actual
      rescue ArgumentError
        # Some objects, like 0-arg lambdas on 1.9+, raise ArgumentError for `expected === actual`.
        false
      end

      # @param expected_array [Array]
      # @param actual_array [Array]
      # @return [<String, String>, nil]
      def array_failure_path_and_message(expected_array, actual_array)
        if expected_array.size != actual_array.size
          return '', "expected #{expected_array.inspect} to have #{actual_array.size} size"
        end

        expected_array.each_with_index do |expected, index|
          next unless (failure = failure_path_and_message(expected, actual_array[index]))

          failure_path, raw_failure_message = failure
          return "[#{index}]" + failure_path, raw_failure_message
        end

        nil
      end

      # @param expected_hash [Hash]
      # @param actual_hash [Hash]
      # @return [<String, String>, nil]
      def hash_failure_path_and_message(expected_hash, actual_hash)
        if expected_hash.size != actual_hash.size
          return '', "expected #{actual_hash.inspect} to have #{expected_hash.size} size"
        end

        expected_hash.each_pair do |expected_key, expected_value|
          if actual_hash.key?(expected_key)
            if (failure = failure_path_and_message(expected_value, actual_hash[expected_key]))
              failure_path, raw_failure_message = failure
              return "[#{expected_key.inspect}]" + failure_path, raw_failure_message
            end
          else
            return '', "expected #{actual_hash.inspect} to have #{expected_key.inspect} key"
          end
        end

        nil
      end

      class << self
        # @api private
        def values_match?(expected, actual)
          new(expected, actual).matched?
        end
      end
    end
  end
end
