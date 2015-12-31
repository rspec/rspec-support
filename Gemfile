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
gem "nokogiri", (RUBY_VERSION < '1.9.3' ? "1.5.2" : ["~> 1.5", "!= 1.6.6.3", "!= 1.6.6.4", "!= 1.6.7.1", "!= 1.6.7"])

gem 'rubocop', "~> 0.23.0", :platform => [:ruby_19, :ruby_20, :ruby_21]

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
