require 'rspec/support/spec/stderr_splitter'
require 'tempfile'

describe 'RSpec::Support::StdErrSplitter' do

  let(:splitter) { RSpec::Support::StdErrSplitter.new stderr }
  let(:stderr)   { STDERR }

  before do
    allow(stderr).to receive(:write)
  end

  around do |example|
    original = $stderr
    $stderr = splitter

    example.run

    $stderr = original
  end

  it 'conforms to the stderr interface' do
    stderr_methods = stderr.methods

    # On 2.2, there's a weird issue where stderr sometimes responds to `birthtime` and sometimes doesn't...
    stderr_methods -= [:birthtime] if RUBY_VERSION =~ /^2\.2/

    # No idea why, but on our AppVeyor windows builds it doesn't respond to these...
    stderr_methods -= [:close_on_exec?, :close_on_exec=] if RSpec::Support::OS.windows?

    expect(splitter).to respond_to(*stderr_methods)
  end

  it 'acknowledges its own interface' do
    expect(splitter).to respond_to :==, :write, :has_output?, :reset!, :verify_example!, :output
  end

  it 'supports methods that stderr supports but StringIO does not' do
    expect(StringIO.new).not_to respond_to(:stat)
    expect(splitter.stat).to be_a(File::Stat)
  end

  it 'supports #to_io' do
    expect(splitter.to_io).to be(stderr.to_io)
  end

  it 'behaves like stderr' do
    splitter.write 'a warning'
    expect(stderr).to have_received(:write)
  end

  it 'pretends to be stderr' do
    expect(splitter).to eq stderr
  end

  it 'resets when reopened' do
    warn 'a warning'
    stderr.unstub(:write)

    Tempfile.open('stderr') do |file|
      splitter.reopen(file)
      splitter.verify_example! self
    end
  end

  it 'tracks when output to' do
    splitter.write 'a warning'
    expect(splitter).to have_output
  end

  it 'will ignore examples without a warning' do
    splitter.verify_example! self
  end

  it 'will ignore examples after a reset a warning' do
    warn 'a warning'
    splitter.reset!
    splitter.verify_example! self
  end

  unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
    it 'will fail an example which generates a warning' do
      true unless @undefined
      expect { splitter.verify_example! self }.to raise_error(/Warnings were generated:/)
    end
  end

end
