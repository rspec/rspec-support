require "spec_helper"
require "rspec/support/warnings"

describe "rspec warnings and deprecations" do
  let(:warning_object) do
    Object.new.tap { |o| o.extend(RSpec::Support::Warnings) }
  end

  context "when rspec-core is not available" do
    shared_examples "falling back to Kernel.warn" do |args|
      let(:method_name) { args.fetch(:method_name) }

      it 'falls back to warning with a plain message' do
        expect(::Kernel).to receive(:warn).with(/message/)
        warning_object.send(method_name, 'message')
      end

      it "handles being passed options" do
        expect(::Kernel).to receive(:warn).with(/message/)
        warning_object.send(method_name, "this is the message", :type => :test)
      end
    end

    it_behaves_like 'falling back to Kernel.warn', :method_name => :deprecate
    it_behaves_like 'falling back to Kernel.warn', :method_name => :warn_deprecation
  end

  shared_examples "warning helper" do |helper|
    it 'warns with the message text' do
      expect(::Kernel).to receive(:warn).with(/Message/)
      warning_object.send(helper, 'Message')
    end

    it 'sets the calling line' do
      expect(::Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__+1}/)
      warning_object.send(helper, 'Message')
    end

    it 'optionally sets the replacement' do
      expect(::Kernel).to receive(:warn).with(/Use Replacement instead./)
      warning_object.send(helper, 'Message', :replacement => 'Replacement')
    end
  end

  describe "#warning" do
    it 'prepends WARNING:' do
      expect(::Kernel).to receive(:warn).with(/WARNING: Message\./)
      warning_object.warning 'Message'
    end

    it_should_behave_like 'warning helper', :warning
  end

  describe "#warn_with message, options" do
    it_should_behave_like 'warning helper', :warn_with
  end
end
