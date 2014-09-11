RSpec::Support.require_rspec_support 'match_expectation_consumer'

module RSpec
  module Support
    # Provides a means to fuzzy-match between two arbitrary objects.
    # Understands array/hash nesting. Uses `===` or `==` to
    # perform the matching.
    module FuzzyMatcher
      # @api private
      def self.values_match?(expected, actual)
        if Array === expected && Enumerable === actual && !(Struct === actual)
          return arrays_match?(expected, actual.to_a)
        elsif Hash === expected && Hash === actual
          return hashes_match?(expected, actual)
        elsif actual == expected
          return true
        end

        begin
          expected === actual
        rescue ArgumentError
          # Some objects, like 0-arg lambdas on 1.9+, raise
          # ArgumentError for `expected === actual`.
          false
        end
      end

      # @private
      def self.arrays_match?(expected_list, actual_list)
        return expected_list == actual_list if expected_list.empty?
        actual_list = actual_list.dup
        consumers = map_to_consumers(expected_list)
        orig_consumers = consumers.dup
        until consumers.empty?
          consumer = consumers.delete_at(0)
          while consumer.can_consume_more_args?
            return orig_consumers.all?(&:accepting?) if actual_list.empty?
            arg = actual_list.delete_at(0)

            consumer.consume(arg)
          end
        end

        orig_consumers.all?(&:accepting?) && actual_list.empty?
      end

      def self.map_to_consumers(expected_list)
        expected_list.map do |expected_value|
          expected_value_is_null_object_double = [
            RSpec::Mocks::Double === expected_value,
            expected_value.respond_to?(:i_respond_to_everything)
          ].all?

          expected_value_can_consume = expected_value.respond_to?(:expectation_consumer)

          if !(expected_value_is_null_object_double) && expected_value_can_consume
            expected_value.expectation_consumer(expected_value)
          else
            MatchExpectationConsumer.new(expected_value)
          end
        end
      end

      # @private
      def self.hashes_match?(expected_hash, actual_hash)
        return false if expected_hash.size != actual_hash.size

        expected_hash.all? do |expected_key, expected_value|
          actual_value = actual_hash.fetch(expected_key) { return false }
          values_match?(expected_value, actual_value)
        end
      end

      private_class_method :arrays_match?, :hashes_match?
    end
  end
end
