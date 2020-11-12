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

      def rbx?
        defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
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
    end
  end
end
