require "spec_helper"

# Make sure we're using the `rspec-support` CallerFilter
# can be removed at a later date
unless RSpec::CallerFilter::RSPEC_LIBS.include? 'support'
  RSpec.send :remove_const, :CallerFilter
  require 'rspec/support/caller_filter'
end
# end cf cleanup #

# Make sure that we're using the warnings code from `rspec-support`
# Can be removed at a later date
%w[rspec/core/warnings rspec/mocks/warnings rspec/expectations/deprecation].each do |file|
  begin
    require file
  rescue LoadError
  end
end

module RSpec
  class << self
    undef deprecate        if defined?(RSpec.deprecate)
    undef warn_deprecation if defined?(RSpec.warn_deprecation)
    undef warning          if defined?(RSpec.warning)
    undef warn_with        if defined?(RSpec.warn_with)
  end
end
# end warnings cleanup #

require 'rspec/support/warnings'

describe "rspec warnings and deprecations" do

  def reset_and_load_warnings
    RSpec.module_eval do
      class << self
        undef deprecate        if defined?(RSpec.deprecate)
        undef warn_deprecation if defined?(RSpec.warn_deprecation)
        undef warning          if defined?(RSpec.warning)
        undef warn_with        if defined?(RSpec.warn_with)
      end
    end
    load 'rspec/support/warnings.rb'
  end

  context "when rspec-core is available" do
    before do
      reset_and_load_warnings
    end
    describe "#deprecate" do
      it "passes the hash to the reporter" do
        expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :deprecated => "deprecated_method", :replacement => "replacement")
        RSpec.deprecate("deprecated_method", :replacement => "replacement")
      end

      it "adds the call site" do
        expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
        RSpec.deprecate("deprecated_method")
      end

      it "doesn't override a passed call site" do
        expect_deprecation_with_call_site("some_file.rb", 17)
        RSpec.deprecate("deprecated_method", :call_site => "/some_file.rb:17")
      end
    end

    describe "#warn_deprecation" do
      it "puts message in a hash" do
        expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :message => "this is the message")
        RSpec.warn_deprecation("this is the message")
      end
    end
  end

  context "when rspec-core is not available" do
    before do
      allow(RSpec).to receive(:const_get).with("Core")
      reset_and_load_warnings
    end

    shared_examples_for "falls back to warn for" do |method|
      it 'falls back to warning with a plain message' do
        expect(::Kernel).to receive(:warn).with /message/
        RSpec.send(method,'message')
      end
    end

    it_behaves_like 'falls back to warn for', :deprecate
    it_behaves_like 'falls back to warn for', :warn_deprecation
  end

  shared_examples_for "warning helper" do |helper|
    it 'warns with the message text' do
      expect(::Kernel).to receive(:warn).with(/Message/)
      RSpec.send(helper, 'Message')
    end

    it 'sets the calling line' do
      expect(::Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__+1}/)
      RSpec.send(helper, 'Message')
    end
  end

  describe "#warning" do
    it 'prepends WARNING:' do
      expect(::Kernel).to receive(:warn).with(/WARNING: Message\./)
      RSpec.warning 'Message'
    end
    it_should_behave_like 'warning helper', :warning
  end

  describe "#warn_with message, options" do
    it_should_behave_like 'warning helper', :warn_with
  end
end
