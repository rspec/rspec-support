module RSpec
  module Support
    # @api private
    #
    # Defines a helper method that is optimized to require files from the
    # named lib. The passed block MUST be `{ |f| require_relative f }`
    # because for `require_relative` to work properly from within the named
    # lib the line of code must be IN that lib.
    #
    # `require_relative` is preferred when available because it is always O(1),
    # regardless of the number of dirs in $LOAD_PATH. `require`, on the other
    # hand, does a linear O(N) search over the dirs in the $LOAD_PATH until
    # it can resolve the file relative to one of the dirs.
    def self.define_optimized_require_for_rspec(lib, &require_relative)
      name = "require_rspec_#{lib}"

      if Kernel.respond_to?(:require_relative)
        (class << self; self; end).__send__(:define_method, name) do |f|
          require_relative.call("#{lib}/#{f}")
        end
      else
        (class << self; self; end).__send__(:define_method, name) do |f|
          require "rspec/#{lib}/#{f}"
        end
      end
    end

    define_optimized_require_for_rspec(:support) { |f| require_relative(f) }
    require_rspec_support "version"

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
        if object_is_a_delegator?(object) && kernel_has_private_method?(method_name) && !object_has_own_method?(object, method_name)
          ::Kernel.method(method_name)
        else
          KERNEL_METHOD_METHOD.bind(object).call(method_name)
        end
      end

      # I came up with two implementations of this, one that does ancestor
      # checking and one that does respond_to __getobj__ checking. I'm not
      # sure which is more appropriate
      def self.object_is_a_delegator?(object)
        object_has_getobj_method?(object)
      end

      def self.object_is_a_delegator?(object)
        object_has_class_method?(object) && object_has_delegator_as_an_ancestor?(object)
      end

      def self.object_has_getobj_method?(object)
       ::Kernel.instance_method(:methods).bind(object).call.include?(:__getobj__)
      end

      def self.object_has_delegator_as_an_ancestor?(object)
         object.class.ancestors.map(&:name).include?("Delegator")
      end

      def self.object_has_class_method?(object)
       ::Kernel.instance_method(:methods).bind(object).call.include?(:class)
      end

      def self.kernel_has_private_method?(method_name)
        ::Kernel.private_instance_methods.include?(method_name)
      end

      def self.object_has_own_method?(object, method_name)
        object.methods.include?(method_name)
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
