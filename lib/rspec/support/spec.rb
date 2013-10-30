require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/stderr_splitter'

$stderr = RSpec::Support::StdErrSplitter.new($stderr)

RSpec.configure do |c|
  c.include RSpecHelpers
end
