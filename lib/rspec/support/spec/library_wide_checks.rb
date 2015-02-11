require 'rspec/support/spec/shell_out'

RSpec.shared_examples_for "library wide checks" do |lib, options|
  consider_a_test_env_file = options.fetch(:consider_a_test_env_file, /MATCHES NOTHING/)
  allowed_loaded_feature_regexps = options.fetch(:allowed_loaded_feature_regexps, [])
  preamble_for_lib = options[:preamble_for_lib]
  preamble_for_spec = "require 'rspec/core'; require 'spec_helper'"

  include RSpec::Support::ShellOut

  define_method :files_to_require_for do |sub_dir|
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

  def command_from(code_lines)
    code_lines.join("\n")
  end

  def load_all_files(files, preamble, postamble=nil)
    requires = files.map { |f| "require '#{f}'" }
    command  = command_from(Array(preamble) + requires + Array(postamble))

    stdout, stderr, status = with_env 'NO_COVERAGE' => '1' do
      options = %w[ -w ]
      options << "--disable=gem" if RUBY_VERSION.to_f >= 1.9 && RSpec::Support::Ruby.mri?
      run_ruby_with_current_load_path(command, *options)
    end

    # Ignore bundler warning.
    stderr = stderr.split("\n").reject { |l| l =~ %r{bundler/source/rubygems} }.join("\n")
    [stdout, stderr, status.exitstatus]
  end

  define_method :load_all_lib_files do
    files = all_lib_files - lib_test_env_files
    preamble  = ['orig_loaded_features = $".dup', preamble_for_lib]
    postamble = [
      'loaded_features = ($" - orig_loaded_features).join("\n")',
      "File.open('#{loaded_features_outfile}', 'w') { |f| f.write(loaded_features) }"
    ]

    load_all_files(files, preamble, postamble)
  end

  define_method :load_all_spec_files do
    files = files_to_require_for("spec") + lib_test_env_files
    load_all_files(files, preamble_for_spec)
  end

  attr_reader :loaded_features_outfile, :all_lib_files, :lib_test_env_files,
              :lib_file_results, :spec_file_results

  before(:context) do
    @loaded_features_outfile = if ENV['CI']
                                 # On AppVeyor we get exit status 5 ("Access is Denied",
                                 # from what I've read) when trying to write to a tempfile.
                                 #
                                 # On Travis, we occasionally get Errno::ENOENT (No such file
                                 # or directory) when reading from a tempfile.
                                 #
                                 # In both cases if we leave a file behind in the current dir,
                                 # it's not a big deal so we put it in the current dir.
                                 File.join(".", "loaded_features.txt")
                               else
                                 # Locally it's nice not to pollute the current working directory
                                 # so we use a tempfile instead.
                                 require 'tempfile'
                                 Tempfile.new("loaded_features.txt").path
                               end

    @all_lib_files            = files_to_require_for("lib")
    @lib_test_env_files       = all_lib_files.grep(consider_a_test_env_file)

    @lib_file_results, @spec_file_results = [
      # Load them in parallel so it's faster...
      Thread.new { load_all_lib_files  },
      Thread.new { load_all_spec_files }
    ].map(&:join).map(&:value)
  end

  def have_successful_no_warnings_output
    eq ["", "", 0]
  end

  it "issues no warnings when loaded", :slow do
    expect(lib_file_results).to have_successful_no_warnings_output
  end

  it "issues no warnings when the spec files are loaded", :slow do
    expect(spec_file_results).to have_successful_no_warnings_output
  end

  it 'only loads a known set of stdlibs so gem authors are forced ' \
     'to load libs they use to have passing specs', :slow do
    loaded_features = File.read(loaded_features_outfile).split("\n")
    if RUBY_VERSION == '1.8.7'
      # On 1.8.7, $" returns the relative require path if that was used
      # to require the file. LIB_REGEX will not match the relative version
      # since it has a `/lib` prefix. Here we deal with this by expanding
      # relative files relative to the $LOAD_PATH dir (lib).
      Dir.chdir("lib") { loaded_features.map! { |f| File.expand_path(f) } }
    end

    loaded_features.reject! { |feature| RSpec::CallerFilter::LIB_REGEX =~ feature }
    loaded_features.reject! { |feature| allowed_loaded_feature_regexps.any? { |r| r =~ feature } }

    expect(loaded_features).to eq([])
  end
end
