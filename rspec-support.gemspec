lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/support/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-support"
  spec.version       = RSpec::Support::Version::STRING
  spec.authors       = ["David Chelimsky","Myron Marson","Jon Rowe","Sam Phippen","Xaviery Shay","Bradley Schaefer"]
  spec.email         = "rspec-users@rubyforge.org"
  spec.homepage      = "https://github.com/rspec/rspec-support"
  spec.summary       = "rspec-support-#{RSpec::Support::Version::STRING}"
  spec.description   = "Support utilities for RSpec gems"
  spec.license       = "MIT"

  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/rspec/rspec-support/issues',
    'changelog_uri'     => "https://github.com/rspec/rspec-support/blob/v#{spec.version}/Changelog.md",
    'documentation_uri' => 'https://rspec.info/documentation/',
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/rspec',
    'source_code_uri'   => 'https://github.com/rspec/rspec-support',
  }

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files         += %w[README.md LICENSE.md Changelog.md]
  spec.test_files    = []
  spec.rdoc_options  = ["--charset=UTF-8"]
  spec.require_paths = ["lib"]

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    spec.signing_key = private_key
    spec.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  spec.required_ruby_version = '>= 2.3.0'
end
