# coding: utf-8
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

  spec.rubyforge_project  = "rspec"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files         += %w[README.md License.txt Changelog.md]
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.rdoc_options  = ["--charset=UTF-8"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.8.7'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake",    "~> 10.0.0"

  spec.add_development_dependency "rspec",   ">= 3.0.0.pre"
end
