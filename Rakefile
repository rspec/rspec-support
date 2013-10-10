require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"

require "rspec/core/rake_task"
require "rspec/core/version"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

task :default => [:spec]
