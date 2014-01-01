require "rspec/support/version"

module RSpec
  module Support
    # @api private
    KERNEL_METHOD_METHOD = ::Kernel.instance_method(:method)

    # @api private
    #
    # Used internally to get a method handle for a particular object
    # and method name.
    #
    # Includes handling for a few special cases:
    #
    #   - Objects that redefine #method (e.g. an HTTPRequest struct)
    #   - BasicObject subclasses that mixin a Kernel dup (e.g. SimpleDelegator)
    if RUBY_VERSION.to_i >= 2 && RUBY_ENGINE != 'rbx'
      def self.method_handle_for(object, method_name)
        KERNEL_METHOD_METHOD.bind(object).call(method_name)
      end
    else
      def self.method_handle_for(object, method_name)
        if ::Kernel === object
          KERNEL_METHOD_METHOD.bind(object).call(method_name)
        else
          object.method(method_name)
        end
      end
    end
  end
end
