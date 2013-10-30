require "spec_helper"
require 'rspec/support/spec/in_sub_process'

# RSpec Core has already loaded these, we wish to test there
# definition so we undefine them first.
module RSpec
  class << self
    undef deprecate        if defined?(RSpec.deprecate)
    undef warn_deprecation if defined?(RSpec.warn_deprecation)
    undef warn_with        if defined?(RSpec.warn_with)
    undef warning          if defined?(RSpec.warning)
  end
end

describe "rspec warnings and deprecations" do
  include RSpec::Support::InSubProcess

  def run_with_rspec_core
    in_sub_process do
      load 'rspec/core/warnings.rb'
      yield
    end
  end

  def run_without_rspec_core
    in_sub_process do
      load 'rspec/support/warnings.rb'
      yield
    end
  end

  context "when rspec-core is available" do
    describe "#deprecate" do
      it "passes the hash to the reporter" do
        run_with_rspec_core do
          expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :deprecated => "deprecated_method", :replacement => "replacement")
          RSpec.deprecate("deprecated_method", :replacement => "replacement")
        end
      end

      it "adds the call site" do
        run_with_rspec_core do
          expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
          RSpec.deprecate("deprecated_method")
        end
      end

      it "doesn't override a passed call site" do
        run_with_rspec_core do
          expect_deprecation_with_call_site("some_file.rb", 17)
          RSpec.deprecate("deprecated_method", :call_site => "/some_file.rb:17")
        end
      end
    end

    describe "#warn_deprecation" do
      it "puts message in a hash" do
        run_with_rspec_core do
          expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :message => "this is the message")
          RSpec.warn_deprecation("this is the message")
        end
      end
    end
  end

  context "when rspec-core is not available" do

    shared_examples_for "falls back to warn for" do |method|
      it 'falls back to warning with a plain message' do
        run_without_rspec_core do
          expect(::Kernel).to receive(:warn).with(/message/)
          RSpec.send(method,'message')
        end
      end
    end

    it_behaves_like 'falls back to warn for', :deprecate
    it_behaves_like 'falls back to warn for', :warn_deprecation
  end

  shared_examples_for "warning helper" do |helper|
    it 'warns with the message text' do
      run_without_rspec_core do
        expect(::Kernel).to receive(:warn).with(/Message/)
        RSpec.send(helper, 'Message')
      end
    end

    it 'sets the calling line' do
      run_without_rspec_core do
        expect(::Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__+1}/)
        RSpec.send(helper, 'Message')
      end
    end
  end

  describe "#warning" do
    it 'prepends WARNING:' do
      run_without_rspec_core do
        expect(::Kernel).to receive(:warn).with(/WARNING: Message\./)
        RSpec.warning 'Message'
      end
    end
    it_should_behave_like 'warning helper', :warning
  end

  describe "#warn_with message, options" do
    it_should_behave_like 'warning helper', :warn_with
  end
end
