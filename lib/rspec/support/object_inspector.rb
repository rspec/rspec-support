RSpec::Support.require_rspec_support "object_formatter"

module RSpec
  module Support
    # @deprecated
    # @private
    # TODO: remove this once rspec-expectations and rspec-mocks
    # have been updated to use `ObjectFormatter`.
    module ObjectInspector
      def self.inspect(object)
        ObjectFormatter.format(object)
      end
    end
  end
end
