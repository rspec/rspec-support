require 'open3'
require 'rake/file_utils'
require 'shellwords'

module RSpec
  module Support
    module ShellOut
      def with_env(vars)
        original = ENV.to_hash
        vars.each { |k, v| ENV[k] = v }

        begin
          yield
        ensure
          ENV.replace(original)
        end
      end

      def shell_out(*command)
        stdout, stderr, status = Open3.capture3(*command)
        return stdout, filter(stderr), status
      end

      def run_ruby_with_current_load_path(ruby_command, *flags)
        command = [
          FileUtils::RUBY,
          "-I#{$LOAD_PATH.map(&:shellescape).join(File::PATH_SEPARATOR)}",
          "-e", ruby_command, *flags
        ]

        # Unset these env vars because `ruby -w` will issue warnings whenever
        # they are set to non-default values.
        with_env 'RUBY_GC_HEAP_FREE_SLOTS' => nil, 'RUBY_GC_MALLOC_LIMIT' => nil,
                 'RUBY_FREE_MIN' => nil do
          shell_out(*command)
        end
      end

      LINES_TO_IGNORE =
        [
          # Ignore bundler warning.
          %r{bundler/source/rubygems},
          # Ignore bundler + rubygems warning.
          %r{site_ruby/\d\.\d\.\d/rubygems},
          %r{jruby-\d\.\d\.\d\.\d/lib/ruby/stdlib/rubygems},
          # This is required for windows for some reason
          %r{lib/bundler/rubygems},
          # These are related to the above, there is a warning about io from FFI
          %r{jruby-\d\.\d\.\d\.\d/lib/ruby/stdlib/io},
          %r{io/console on JRuby shells out to stty for most operations},
        ]

      def strip_known_warnings(input)
        input.split("\n").reject do |l|
          LINES_TO_IGNORE.any? { |to_ignore| l =~ to_ignore } ||
          # Remove blank lines
          l == "" || l.nil?
        end.join("\n")
      end

    private

      if Ruby.jruby?
        def filter(output)
          output.each_line.reject do |line|
            line.include?("lib/ruby/shared/rubygems/defaults/jruby")
          end.join($/)
        end
      else
        def filter(output)
          output
        end
      end
    end
  end
end
