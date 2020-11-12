require 'rbconfig'

module RSpec
  module Support
    # @api private
    #
    # Provides query methods for different OS or OS features.
    module OS
    module_function

      def windows?
        !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
      end

      def windows_file_path?
        ::File::ALT_SEPARATOR == '\\'
      end
    end

    # @api private
    #
    # Provides query methods for different rubies
    module Ruby
    module_function

      def jruby?
        RUBY_PLATFORM == 'java'
      end

      def jruby_9000?
        jruby? && JRUBY_VERSION >= '9.0.0.0'
      end

      def rbx?
        defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      end

      def non_mri?
        !mri?
      end

      def mri?
        !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby'
      end

      def truffleruby?
        defined?(RUBY_ENGINE) && RUBY_ENGINE == 'truffleruby'
      end
    end

    # @api private
    #
    # Provides query methods for ruby features that differ among
    # implementations.
    module RubyFeatures
    module_function

      def fork_supported?
        Process.respond_to?(:fork)
      end

      def optional_and_splat_args_supported?
        Method.method_defined?(:parameters)
      end

      def caller_locations_supported?
        respond_to?(:caller_locations, true)
      end

      if Exception.method_defined?(:cause)
        def supports_exception_cause?
          true
        end
      else
        def supports_exception_cause?
          false
        end
      end

      if RUBY_VERSION.to_f >= 2.7
        def supports_taint?
          false
        end
      else
        def supports_taint?
          true
        end
      end

      if Ruby.rbx?
        def ripper_supported?
          false
        end
      else
        def ripper_supported?
          true
        end
      end

      if Ruby.mri?
        def kw_args_supported?
          RUBY_VERSION >= '2.0.0'
        end

        def required_kw_args_supported?
          RUBY_VERSION >= '2.1.0'
        end

        def supports_rebinding_module_methods?
          RUBY_VERSION.to_i >= 2
        end
      else
        # RBX / JRuby et al support is unknown for keyword arguments
        begin
          eval("o = Object.new; def o.m(a: 1); end;"\
               " raise SyntaxError unless o.method(:m).parameters.include?([:key, :a])")

          def kw_args_supported?
            true
          end
        rescue SyntaxError
          def kw_args_supported?
            false
          end
        end

        begin
          eval("o = Object.new; def o.m(a: ); end;"\
               "raise SyntaxError unless o.method(:m).parameters.include?([:keyreq, :a])")

          def required_kw_args_supported?
            true
          end
        rescue SyntaxError
          def required_kw_args_supported?
            false
          end
        end

        begin
          Module.new { def foo; end }.instance_method(:foo).bind(Object.new)

          def supports_rebinding_module_methods?
            true
          end
        rescue TypeError
          def supports_rebinding_module_methods?
            false
          end
        end
      end

      def module_refinement_supported?
        Module.method_defined?(:refine) || Module.private_method_defined?(:refine)
      end

      def module_prepends_supported?
        Module.method_defined?(:prepend) || Module.private_method_defined?(:prepend)
      end
    end
  end
end
