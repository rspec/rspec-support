require 'benchmark'

RANGE = (1..100)

def sym_to_proc_with_map
  RANGE.map(&:to_s)
end

def sym_to_proc_with_each
  RANGE.each(&:to_s)
end

def block_with_map
  RANGE.map { |i| i.to_s }
end

def block_with_each
  RANGE.each { |i| i.to_s }
end

begin
  require 'benchmark/ips'

  [10, 100, 1000, 10_000].each do |size|
    range = (1..size)

    puts "\nUsing Array#map size #{size}:"
    Benchmark.ips do |x|
      x.report('Block         ') { range.map { |i| i.to_s } }
      x.report('Symbol#to_proc') { range.map(&:to_s) }
      x.compare!
    end

    puts "Using Array#each size #{size}:"
    Benchmark.ips do |x|
      x.report('Block         ') { range.each { |i| i.to_s } }
      x.report('Symbol#to_proc') { range.each(&:to_s) }
      x.compare!
    end
  end
rescue LoadError
  # We are on an older Ruby which does not support benchmark/ips
  n = 100_000

  Benchmark.benchmark do |bm|
    puts
    puts "#{n} times - ruby #{RUBY_VERSION}"

    puts
    puts "symbol to proc (map)"
    3.times { bm.report { n.times { sym_to_proc_with_map } } }

    puts
    puts "block (map)"
    3.times { bm.report { n.times { block_with_map } } }

    puts
    puts "symbol to proc (each)"
    3.times { bm.report { n.times { sym_to_proc_with_each } } }

    puts
    puts "block (each)"
    3.times { bm.report { n.times { block_with_each } } }
  end
end

__END__

I was very surprised by this benchmark. My memory seemed to always remember
being told that using a block was faster than calling symbol to proc. This was
true for Ruby 1.8.7 (including REE and JRuby) but was not true for Ruby 1.9 and
2.0, 2.1, and 2.2. For Ruby 1.9 and 2.x sometimes the block was faster for
small enumerable sizes, but the difference in those cases was negligable.

A larger list of benchmarks is available in the output reported by the
following Travis CI build:

https://travis-ci.org/rspec/rspec-support/builds/73746126

It seems that going forward it is likely that we should switch to using symbol
to proc. [Aaron Kromer]


100000 times - ruby 1.8.7

symbol to proc (map)
  8.010000   0.040000   8.050000 (  8.085102)
  8.260000   0.030000   8.290000 (  8.343247)
  8.510000   0.060000   8.570000 (  8.790371)

block (map)
  5.530000   0.040000   5.570000 (  5.637928)
  5.540000   0.040000   5.580000 (  5.652807)
  5.530000   0.040000   5.570000 (  5.647678)

symbol to proc (each)
  6.410000   0.050000   6.460000 (  6.568056)
  6.430000   0.040000   6.470000 (  6.544043)
  6.380000   0.040000   6.420000 (  6.470070)

block (each)
  4.230000   0.020000   4.250000 (  4.273692)
  4.210000   0.020000   4.230000 (  4.255388)
  4.220000   0.020000   4.240000 (  4.264383)


ruby 1.9.3p547 (2014-05-14) [x86_64-darwin14.0.0]
Using Array#map size 10:
  Comparison:
        Block         :   225844.6 i/s
        Symbol#to_proc:   224433.3 i/s - 1.01x slower

Using Array#each size 10:
  Comparison:
        Symbol#to_proc:   359495.0 i/s
        Block         :   317313.7 i/s - 1.13x slower


Using Array#map size 100:
  Comparison:
        Symbol#to_proc:    28015.5 i/s
        Block         :    26334.1 i/s - 1.06x slower

Using Array#each size 100:
  Comparison:
        Symbol#to_proc:    38636.7 i/s
        Block         :    32242.8 i/s - 1.20x slower


Using Array#map size 1000:
  Comparison:
        Symbol#to_proc:     3720.9 i/s
        Block         :     3388.1 i/s - 1.10x slower

Using Array#each size 1000:
  Comparison:
        Symbol#to_proc:     5116.9 i/s
        Block         :     4087.2 i/s - 1.25x slower


Using Array#map size 10000:
  Comparison:
        Symbol#to_proc:      359.8 i/s
        Block         :      258.5 i/s - 1.39x slower

Using Array#each size 10000:
  Comparison:
        Symbol#to_proc:      470.1 i/s
        Block         :      388.6 i/s - 1.21x slower


ruby 2.0.0p576 (2014-09-19) [x86_64-darwin14.0.0]
Using Array#map size 10:
  Comparison:
        Block         :   234459.4 i/s
        Symbol#to_proc:   232139.1 i/s - 1.01x slower

Using Array#each size 10:
  Comparison:
        Symbol#to_proc:   365396.5 i/s
        Block         :   341559.2 i/s - 1.07x slower


Using Array#map size 100:
  Comparison:
        Symbol#to_proc:    28839.2 i/s
        Block         :    27606.0 i/s - 1.04x slower

Using Array#each size 100:
  Comparison:
        Symbol#to_proc:    40908.2 i/s
        Block         :    36646.3 i/s - 1.12x slower


Using Array#map size 1000:
  Comparison:
        Symbol#to_proc:     2446.4 i/s
        Block         :     2149.2 i/s - 1.14x slower

Using Array#each size 1000:
  Comparison:
        Symbol#to_proc:     3747.5 i/s
        Block         :     3030.8 i/s - 1.24x slower


Using Array#map size 10000:
  Comparison:
        Symbol#to_proc:      356.3 i/s
        Block         :      336.7 i/s - 1.06x slower

Using Array#each size 10000:
  Comparison:
        Symbol#to_proc:      485.6 i/s
        Block         :      414.0 i/s - 1.17x slower


ruby 2.1.5p273 (2014-11-13 revision 48405) [x86_64-darwin14.0]
Using Array#map size 10:
  Comparison:
        Symbol#to_proc:   232131.3 i/s
        Block         :   226938.7 i/s - 1.02x slower

Using Array#each size 10:
  Comparison:
        Symbol#to_proc:   406072.3 i/s
        Block         :   382604.5 i/s - 1.06x slower


Using Array#map size 100:
  Comparison:
        Symbol#to_proc:    36333.6 i/s
        Block         :    31873.8 i/s - 1.14x slower

Using Array#each size 100:
  Comparison:
        Symbol#to_proc:    52197.2 i/s
        Block         :    43321.5 i/s - 1.20x slower


Using Array#map size 1000:
  Comparison:
        Symbol#to_proc:     3119.2 i/s
        Block         :     2896.9 i/s - 1.08x slower

Using Array#each size 1000:
  Comparison:
        Symbol#to_proc:     4161.0 i/s
        Block         :     3942.1 i/s - 1.06x slower


Using Array#map size 10000:
  Comparison:
        Symbol#to_proc:      311.5 i/s
        Block         :      199.0 i/s - 1.57x slower

Using Array#each size 10000:
  Comparison:
        Symbol#to_proc:      507.8 i/s
        Block         :      426.2 i/s - 1.19x slower


ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]
Using Array#map size 10:
  Comparison:
        Block         :   275271.0 i/s
        Symbol#to_proc:   261591.5 i/s - 1.05x slower

Using Array#each size 10:
  Comparison:
        Symbol#to_proc:   512647.5 i/s
        Block         :   470755.8 i/s - 1.09x slower


Using Array#map size 100:
  Comparison:
        Symbol#to_proc:    37350.5 i/s
        Block         :    36772.7 i/s - 1.02x slower

Using Array#each size 100:
  Comparison:
        Symbol#to_proc:    58635.6 i/s
        Block         :    50240.9 i/s - 1.17x slower


Using Array#map size 1000:
  Comparison:
        Block         :     3715.4 i/s
        Symbol#to_proc:     3677.0 i/s - 1.01x slower

Using Array#each size 1000:
  Comparison:
        Symbol#to_proc:     5587.5 i/s
        Block         :     4597.9 i/s - 1.22x slower


Using Array#map size 10000:
  Comparison:
        Symbol#to_proc:      355.2 i/s
        Block         :      339.1 i/s - 1.05x slower

Using Array#each size 10000:
  Comparison:
        Symbol#to_proc:      518.2 i/s
        Block         :      444.1 i/s - 1.17x slower


ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]
Using Array#map size 10:
  Comparison:
        Symbol#to_proc:   298189.1 i/s
        Block         :   295415.7 i/s - 1.01x slower

Using Array#each size 10:
  Comparison:
        Symbol#to_proc:   517869.4 i/s
        Block         :   449633.0 i/s - 1.15x slower


Using Array#map size 100:
  Comparison:
        Symbol#to_proc:    33502.5 i/s
        Block         :    31585.9 i/s - 1.06x slower

Using Array#each size 100:
  Comparison:
        Symbol#to_proc:    54738.3 i/s
        Block         :    44457.9 i/s - 1.23x slower


Using Array#map size 1000:
  Comparison:
        Symbol#to_proc:     3431.9 i/s
        Block         :     3190.7 i/s - 1.08x slower

Using Array#each size 1000:
  Comparison:
        Symbol#to_proc:     5590.9 i/s
        Block         :     4660.6 i/s - 1.20x slower


Using Array#map size 10000:
  Comparison:
        Symbol#to_proc:      353.3 i/s
        Block         :      344.5 i/s - 1.03x slower

Using Array#each size 10000:
  Comparison:
        Symbol#to_proc:      526.5 i/s
        Block         :      437.1 i/s - 1.20x slower
