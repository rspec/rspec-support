unless ENV['NO_COVERALLS']
  require 'simplecov' if RUBY_VERSION.to_f > 1.8
  require 'coveralls'
  Coveralls.wear! do
    add_filter '/bundle/'
    add_filter '/spec/'
    add_filter '/tmp/'
  end
end

require 'rspec/support/spec'
