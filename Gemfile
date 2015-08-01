source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-support.gemspec
gemspec

branch = File.read(File.expand_path("../maintenance-branch", __FILE__)).chomp
%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => branch
  end
end

### dep for ci/coverage
gem 'simplecov', '~> 0.8'

# There is no platform :ruby_193 and Rubocop only supports >= 1.9.3
unless RUBY_VERSION == "1.9.2"
  gem "rubocop",
      "~> 0.32.1",
      :platform => [:ruby_19, :ruby_20, :ruby_21, :ruby_22]
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
