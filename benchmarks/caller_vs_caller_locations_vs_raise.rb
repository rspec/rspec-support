require 'benchmark/ips'

def use_raise_to_capture_caller
  use_raise_lazily.backtrace
end

def use_raise_lazily
  raise "nope"
rescue StandardError => exception
  return exception
end


Benchmark.ips do |x|
  x.report("caller()              ") { caller }
  x.report("caller_locations()    ") { caller_locations }
  x.report("raise with backtrace  ") { use_raise_to_capture_caller }
  x.report("raise and store (lazy)") { use_raise_lazily }
  x.report("caller(1, 2)          ") { caller(1, 2) }
  x.report("caller_locations(1, 2)") { caller_locations(1, 2) }
end

__END__
Calculating -------------------------------------
caller()
                        13.545k i/100ms
caller_locations()
                        30.468k i/100ms
raise with backtrace
                         7.592k i/100ms
raise and store (lazy)
                        44.955k i/100ms
caller(1, 2)
                        38.374k i/100ms
caller_locations(1, 2)
                        54.631k i/100ms
-------------------------------------------------
caller()
                        140.795k (± 7.0%) i/s -    704.340k
caller_locations()
                        376.708k (± 7.3%) i/s -      1.889M
raise with backtrace
                         87.993k (± 7.7%) i/s -    440.336k
raise and store (lazy)
                        631.806k (± 7.8%) i/s -      3.192M
caller(1, 2)
                        458.055k (± 8.7%) i/s -      2.302M
caller_locations(1, 2)
                        886.157k (± 9.7%) i/s -      4.425M
