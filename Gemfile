source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-support.gemspec
gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  end
end

### dep for ci/coverage
gem 'coveralls', :require => false

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
