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
      specify "#module_refinedment_supported? reflects refinement support" do
        if Ruby.mri? && RUBY_VERSION >= '2.1.0'
          expect(RubyFeatures.module_refinement_supported?).to eq true
        end
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
        it 'does not load Ripper' do
          expect { RubyFeatures.ripper_supported? }.not_to change { defined?(::Ripper) }
        end

        describe 'Ripper' do
          let(:line_number) do
            token = tokens.first
            location = token.first
            location.first
          end

          let(:tokens) do
            require 'ripper'
            ::Ripper.lex('foo')
          end

          if Ruby.mri?
            context 'on MRI' do
              context '1.8.x', :if => RUBY_VERSION.start_with?('1.8.') do
                it 'is not supported' do
                  expect { tokens }.to raise_error(LoadError)
                end
              end

              context '1.9.x or later', :if => RUBY_VERSION >= '1.9' do
                it 'is supported' do
                  expect(line_number).to eq(1)
                end
              end
            end
          end

          if Ruby.jruby?
            context 'on JRuby' do
              context '1.7.x', :if => JRUBY_VERSION.start_with?('1.7.') do
                context 'in 1.8 mode', :if => RUBY_VERSION.start_with?('1.8.') do
                  it 'is not supported' do
                    expect { tokens }.to raise_error(NameError)
                  end
                end

                context 'in non 1.8 mode', :unless => RUBY_VERSION.start_with?('1.8.') do
                  it 'is supported' do
                    expect(line_number).to eq(1)
                  end
                end
              end

              context '9.0.x.x', :if => JRUBY_VERSION.start_with?('9.0') do
                it 'reports wrong line number' do
                  expect(line_number).to eq(2)
                end
              end

              context '9.1.x.x', :if => JRUBY_VERSION.start_with?('9.1') do
                it 'is supported' do
                  expect(line_number).to eq(1)
                end
              end
            end
          end
        end
      end
    end
  end
end
