module RSpec
  module Support
    class MatchExpectationConsumer
      def initialize(expected)
        @expected = expected
        @can_consume_more_args = true
        @accepting = false
      end

      def can_consume_more_args?
        @can_consume_more_args
      end

      def consume(arg)
        @can_consume_more_args = false
        @accepting = (RSpec::Support::FuzzyMatcher.values_match?(@expected, arg))
      end

      def accepting?
        @accepting
      end
    end
  end
end
