require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/stderr_splitter'

warning_preventer = $stderr = RSpec::Support::StdErrSplitter.new($stderr)

RSpec.configure do |c|
  c.include RSpecHelpers
  c.include RSpec::Support::WithIsolatedStdErr
  c.before do
    warning_preventer.reset!
  end
  c.after do |example|
    warning_preventer.verify_example!(example)
  end
end
