require 'tmpdir'
Dir.mkdir("./tmp") unless File.directory?("./tmp")

RSpec.shared_context "isolated directory", :isolated_directory => true do
  around do |ex|
    Dir.mktmpdir(nil, "./tmp") do |tmp_dir|
      Dir.chdir(tmp_dir, &ex)
    end
  end
end
