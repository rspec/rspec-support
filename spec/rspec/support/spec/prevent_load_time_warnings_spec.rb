require 'rspec/support/spec/prevent_load_time_warnings'

RSpec.describe RSpec::Support::WarningsPrevention do
  include described_class

  it 'finds all the files for the named lib and extracts the portion to require' do
    files = files_to_require_for("rspec-support")
    expect(files).to include("rspec/support", "rspec/support/spec/prevent_load_time_warnings")
  end
end
