source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-support.gemspec
gemspec

branch = File.read(File.expand_path("../maintenance-branch", __FILE__)).chomp
%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => branch
  end
end

if RUBY_VERSION < '1.9.3'
  gem 'rake', '< 11.0.0' # rake 11 requires Ruby 1.9.3 or later
elsif RUBY_VERSION < '2.0.0'
  gem 'rake', '< 12.0.0' # rake 12 requires Ruby 2.0.0 or later
else
  gem 'rake', '>= 12.3.2'
end

### dep for ci/coverage
gem 'simplecov', '~> 0.8'

if RUBY_VERSION < '2.0.0' || RUBY_ENGINE == 'java'
  gem 'json', '< 2.0.0' # is a dependency of simplecov
end

if RUBY_VERSION < '2.2.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem 'ffi', '< 1.10'
elsif RUBY_VERSION < '2.0'
  # ffi dropped Ruby 1.8 support in 1.9.19 and Ruby 1.9 support in 1.11.0
  gem 'ffi', '< 1.9.19'
else
  gem 'ffi', '~> 1.11.0'
end

# No need to run rubocop on earlier versions
if RUBY_VERSION >= '2.4' && RUBY_ENGINE == 'ruby'
  gem "rubocop", "~> 0.52.1"
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
