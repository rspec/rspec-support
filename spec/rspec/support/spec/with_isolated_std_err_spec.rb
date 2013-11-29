require 'rspec/support/spec'

describe 'isolating a spec from the stderr splitter' do
  include RSpec::Support::WithIsolatedStdErr

  it 'allows a spec to output a warning' do
    with_isolated_stderr do
      $stderr.puts "Imma gonna warn you"
    end
  end
end
