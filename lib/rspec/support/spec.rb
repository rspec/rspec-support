require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/stderr_splitter'

warning_preventer = $stderr = RSpec::Support::StdErrSplitter.new($stderr)

RSpec.configure do |c|
  c.include RSpecHelpers
  c.before do
    warning_preventer.reset!
  end
  c.after do |example|
    warning_preventer.verify_example!(example)
  end
end
