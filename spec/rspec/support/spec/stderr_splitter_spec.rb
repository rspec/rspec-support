require 'rspec/support/spec/stderr_splitter'

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
    stderr.methods.each do |method_name|
      expect(splitter).to respond_to method_name
    end
  end

  it 'behaves like stderr' do
    splitter.write 'a warning'
    expect(stderr).to have_received(:write)
  end

  it 'pretends to be stderr' do
    expect(splitter).to eq stderr
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

  it 'will fail an example which generates a warning' do
    true unless @undefined
    expect { splitter.verify_example! self }.to raise_error(/Warnings were generated:/)
  end

end
