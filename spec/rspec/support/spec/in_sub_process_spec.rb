require 'rspec/support/spec/in_sub_process'

describe 'isolating code to a sub process' do
  include RSpec::Support::InSubProcess

  it 'isolates the block from the main process' do
    in_sub_process do
      module NotIsolated
      end
      expect(defined? NotIsolated).to eq "constant"
    end
    expect(defined? NotIsolated).to be_nil
  end

  if Process.respond_to?(:fork) && !(RUBY_PLATFORM == 'java' && RUBY_VERSION == '1.8.7')

    it 'captures and reraises errors to the main process' do
      expect {
        in_sub_process { raise "An Internal Error" }
      }.to raise_error "An Internal Error"
    end

    it 'captures and reraises test failures' do
      expect {
        in_sub_process { expect(true).to be false }
      }.to raise_error(/expected false/)
    end

  else

    it 'pends the block' do
      expect { in_sub_process { true } }.to raise_error(/This spec requires forking to work properly/)
    end

  end
end
