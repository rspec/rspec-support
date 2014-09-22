require 'rspec/support/os'

module RSpec
  module Support
    describe OS do

      describe ".windows?" do
        %w[cygwin mswin mingw bccwin wince emx].each do |fragment|
          it "returns true when host os is #{fragment}" do
            stub_const("RbConfig::CONFIG", 'host_os' => fragment)
            expect(OS).to be_windows
          end
        end

        %w[darwin linux].each do |fragment|
          it "returns false when host os is #{fragment}" do
            stub_const("RbConfig::CONFIG", 'host_os' => fragment)
            expect(OS).to_not be_windows
          end
        end
      end

      describe ".windows_file_path?" do
        it "returns true when the file alt seperator is a colon" do
          stub_const("File::ALT_SEPARATOR", ":") unless OS.windows?
          expect(OS).to be_windows_file_path
        end

        it "returns false when file alt seperator is not present" do
          stub_const("File::ALT_SEPARATOR", nil) if OS.windows?
          expect(OS).to_not be_windows_file_path
        end
      end
    end
  end
end
