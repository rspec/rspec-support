require 'rspec/support/spec/shell_out'

module RSpec
  module Support
    module WarningsPrevention
      def files_to_require_for(lib, sub_dir)
        slash         = File::SEPARATOR
        lib_path_re   = /#{slash + lib}[^#{slash}]*#{slash}lib/
        load_path     = $LOAD_PATH.grep(lib_path_re).first
        directory     = load_path.sub(/lib$/, sub_dir)
        files         = Dir["#{directory}/**/*.rb"]
        extract_regex = /#{Regexp.escape(directory) + File::SEPARATOR}(.+)\.rb$/

        # We sort to ensure the files are loaded in a consistent order, regardless
        # of OS. Otherwise, it could load in a different order on Travis than
        # locally, and potentially trigger a "circular require considered harmful"
        # warning or similar.
        files.sort.map { |file| file[extract_regex, 1] }
      end
    end
  end
end

RSpec.shared_examples_for "a library that issues no warnings when loaded" do |lib, *preamble_stmnts|
  include RSpec::Support::ShellOut
  include RSpec::Support::WarningsPrevention

  define_method :expect_no_warnings_from_files_in do |sub_dir, *pre_stmnts|
    # We want to explicitly load every file because each lib has some files that
    # aren't automatically loaded, instead being delayed based on an autoload
    # (such as for rspec-expectations' matchers) or based on a config option
    # (e.g. `config.mock_with :rr` => 'rspec/core/mocking_adapters/rr').
    files_to_require = files_to_require_for(lib, sub_dir)
    statements = pre_stmnts + files_to_require.map do |file|
      "require '#{file}'"
    end

    command = statements.join("; ")

    stdout, stderr, status = with_env 'NO_COVERAGE' => '1' do
      run_ruby_with_current_load_path(command, "-w")
    end

    expect(stdout).to eq("")
    expect(stderr).to eq("")
    expect(status.exitstatus).to eq(0)
  end

  it "issues no warnings when loaded", :slow do
    expect_no_warnings_from_files_in "lib", *preamble_stmnts
  end

  it "issues no warnings when the spec files are loaded", :slow do
    expect_no_warnings_from_files_in "spec", "require 'rspec/core'; require 'spec_helper'"
  end
end
