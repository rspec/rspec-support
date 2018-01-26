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

      specify "jruby_9000? reflects the state of RUBY_PLATFORM and JRUBY_VERSION" do
        stub_const("RUBY_PLATFORM", "java")
        stub_const("JRUBY_VERSION", "")
        expect(Ruby).to_not be_jruby_9000
        stub_const("JRUBY_VERSION", "9.0.3.0")
        expect(Ruby).to be_jruby_9000
        stub_const("RUBY_PLATFORM", "")
        expect(Ruby).to_not be_jruby_9000
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
      specify "#module_refinement_supported? reflects refinement support" do
        if Ruby.mri? && RUBY_VERSION >= '2.1.0'
          expect(RubyFeatures.module_refinement_supported?).to eq true
        end
      end

      specify "#fork_supported? exists" do
        RubyFeatures.fork_supported?
      end

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

      describe "#ripper_supported?" do
        def ripper_is_implemented?
          in_sub_process_if_possible do
            begin
              require 'ripper'
              !!defined?(::Ripper)
            rescue LoadError
              false
            end
          end
        end

        def ripper_works_correctly?
          ripper_reports_correct_line_number? &&
            ripper_can_parse_source_including_keywordish_symbol?
        end

        # https://github.com/jruby/jruby/issues/3386
        def ripper_reports_correct_line_number?
          in_sub_process_if_possible do
            require 'ripper'
            tokens = ::Ripper.lex('foo')
            token = tokens.first
            location = token.first
            line_number = location.first
            line_number == 1
          end
        end

        # https://github.com/jruby/jruby/issues/4562
        def ripper_can_parse_source_including_keywordish_symbol?
          in_sub_process_if_possible do
            require 'ripper'
            sexp = ::Ripper.sexp(':if')
            !sexp.nil?
          end
        end

        it 'returns whether Ripper is correctly implemented in the current environment' do
          expect(RubyFeatures.ripper_supported?).to eq(ripper_is_implemented? && ripper_works_correctly?)
        end

        it 'does not load Ripper' do
          expect { RubyFeatures.ripper_supported? }.not_to change { defined?(::Ripper) }
        end
      end
    end
  end
end
