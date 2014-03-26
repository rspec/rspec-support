require 'rspec/support'
RSpec::Support.require_rspec_support "spec/deprecation_helpers"
RSpec::Support.require_rspec_support "spec/with_isolated_stderr"
RSpec::Support.require_rspec_support "spec/stderr_splitter"
RSpec::Support.require_rspec_support "spec/formatting_support"

warning_preventer = $stderr = RSpec::Support::StdErrSplitter.new($stderr)

RSpec.configure do |c|
  c.include RSpecHelpers
  c.include RSpec::Support::WithIsolatedStdErr
  c.include RSpec::Support::FormattingSupport

  unless defined?(Debugger) # debugger causes warnings when used
    c.before do
      warning_preventer.reset!
    end

    c.after do |example|
      warning_preventer.verify_example!(example)
    end
  end

  if c.files_to_run.one?
    c.full_backtrace = true
    c.default_formatter = 'doc'
  end

  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end

module RSpec::Support::Spec
  def self.setup_simplecov(&block)
    # Simplecov emits some ruby warnings when loaded, so silence them.
    old_verbose, $VERBOSE = $VERBOSE, false

    return if ENV['NO_COVERAGE'] || RUBY_VERSION < '1.9.3' || RUBY_ENGINE != 'ruby'

    # Don't load it when we're running a single isolated
    # test file rather than the whole suite.
    return if RSpec.configuration.files_to_run.one?

    require 'simplecov'

    SimpleCov.start do
      add_filter "./bundle/"
      add_filter "./tmp/"
      add_filter do |source_file|
        # Filter out `spec` directory except when it is under `lib`
        # (as is the case in rspec-support)
        source_file.filename.include?('/spec/') && !source_file.filename.include?('/lib/')
      end

      instance_eval(&block) if block
    end
  rescue LoadError
  ensure
    $VERBOSE = old_verbose
  end
end

