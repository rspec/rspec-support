require 'rspec/support/ruby_features'

module RSpec
  module Support
    describe OS do

      describe ".windows?" do
        %w[cygwin mswin mingw bccwin wince emx].each do |fragment|
          it "returns true when host os is #{fragment}" do
            stub_const("RbConfig::CONFIG", 'host_os' => fragment)
            expect(OS.windows?).to be true
          end
        end

        %w[darwin linux].each do |fragment|
          it "returns false when host os is #{fragment}" do
            stub_const("RbConfig::CONFIG", 'host_os' => fragment)
            expect(OS.windows?).to be false
          end
        end
      end

      describe ".windows_file_path?" do
        it "returns true when the file alt seperator is a colon" do
          stub_const("File::ALT_SEPARATOR", "\\") unless OS.windows?
          expect(OS).to be_windows_file_path
        end

        it "returns false when file alt seperator is not present" do
          stub_const("File::ALT_SEPARATOR", nil) if OS.windows?
          expect(OS).to_not be_windows_file_path
        end
      end
    end

    describe Ruby do
      specify "jruby? reflects the state of RUBY_PLATFORM" do
        stub_const("RUBY_PLATFORM", "java")
        expect(Ruby).to be_jruby
        stub_const("RUBY_PLATFORM", "")
        expect(Ruby).to_not be_jruby
      end

      specify "rbx? reflects the state of RUBY_ENGINE" do
        stub_const("RUBY_ENGINE", "rbx")
        expect(Ruby).to be_rbx
        hide_const("RUBY_ENGINE")
        expect(Ruby).to_not be_rbx
      end

      specify "rbx? reflects the state of RUBY_ENGINE" do
        hide_const("RUBY_ENGINE")
        expect(Ruby).to be_mri
        stub_const("RUBY_ENGINE", "ruby")
        expect(Ruby).to be_mri
        stub_const("RUBY_ENGINE", "rbx")
        expect(Ruby).to_not be_mri
      end
    end

    describe RubyFeatures do
      specify "#supports_exception_cause? exists" do
        RubyFeatures.supports_exception_cause?
      end

      specify "#kw_args_supported? exists" do
        RubyFeatures.kw_args_supported?
      end

      specify "#required_kw_args_supported? exists" do
        RubyFeatures.required_kw_args_supported?
      end

      specify "#supports_rebinding_module_methods? exists" do
        RubyFeatures.supports_rebinding_module_methods?
      end

      specify "#caller_locations_supported? exists" do
        RubyFeatures.caller_locations_supported?
        if Ruby.mri?
          expect(RubyFeatures.caller_locations_supported?).to eq(RUBY_VERSION >= '2.0.0')
        end
      end
    end
  end
end
