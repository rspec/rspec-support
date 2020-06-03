require 'benchmark/ips'
require 'rspec/support'
require 'rspec/support/with_keywords_when_needed'

klass = Class.new do
  def test(*args, **kwargs)
  end
end

def object_under_test
  @object_under_test
end

def object_under_test=(other)
  @object_under_test = other
end
self.object_under_test = klass.new

def send_args
  object_under_test.__send__(:test, 1, 2, 3)
end

def send_to_args
  RSpec::Support::WithKeywordsWhenNeeded.send_to(object_under_test, :test, 1, 2, 3)
end

def send_kw_args
  object_under_test.__send__(:test, 1, 2, 3, some: :keywords)
end

def send_to_kw_args
  RSpec::Support::WithKeywordsWhenNeeded.send_to(object_under_test, :test, 1, 2, 3, some: :keywords)
end

Benchmark.ips do |x|
  x.report("send(*args)             ") { send_args }
  x.report("send_to(*args)          ") { send_to_args }
  x.report("send(*args, **kwargs)   ") { send_kw_args }
  x.report("send_to(*args, **kwargs)") { send_to_kw_args }
end

__END__

send(*args)
                          3.497M (± 1.5%) i/s -     17.523M in   5.011708s
send_to(*args)
                        421.150k (± 2.7%) i/s -      2.141M in   5.088845s
send(*args, **kwargs)
                          2.953M (± 2.7%) i/s -     14.895M in   5.048778s
send_to(*args, **kwargs)
                         49.044k (± 6.6%) i/s -    244.542k in   5.013102s
