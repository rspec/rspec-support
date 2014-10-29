module RSpec
  module Support
    # @api private
    #
    # Provides query methods for different OS or OS features.
    module OS
      def windows?
        RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/
      end
      module_function :windows?

      def windows_file_path?
        ::File::ALT_SEPARATOR == '\\'
      end
      module_function :windows_file_path?
    end

    # @api private
    #
    # Provides query methods for different rubies
    module Ruby
      def jruby?
        RUBY_PLATFORM == 'java'
      end
      module_function :jruby?
    end

    # @api private
    #
    # Provides query methods for ruby features that differ among
    # implementations.
    module RubyFeatures
      def optional_and_splat_args_supported?
        Method.method_defined?(:parameters)
      end
      module_function :optional_and_splat_args_supported?

      def kw_args_supported?
        RUBY_VERSION >= '2.0.0' && RUBY_ENGINE != 'rbx' && RUBY_ENGINE != 'jruby'
      end
      module_function :kw_args_supported?

      def required_kw_args_supported?
        RUBY_VERSION >= '2.1.0' && RUBY_ENGINE != 'rbx' && RUBY_ENGINE != 'jruby'
      end
      module_function :required_kw_args_supported?

      def module_prepends_supported?
        Module.method_defined?(:prepend) || Module.private_method_defined?(:prepend)
      end
      module_function :module_prepends_supported?

      def supports_rebinding_module_methods?
        # RBX and JRuby don't yet support this.
        RUBY_VERSION.to_i >= 2 && RUBY_ENGINE != 'rbx' && RUBY_ENGINE != 'jruby'
      end
      module_function :supports_rebinding_module_methods?
    end
  end
end
