require 'benchmark'

class SequentialWidget
  def initialize
    a = 1
    b = 2
  end
end

def sequential_initialize_assignment
  SequentialWidget.new
end

class ParallelWidget
  def initialize
    a, b = 1, 2
  end
end

def parallel_initialize_assignment
  ParallelWidget.new
end

def sequential_local_assignment
  a = 1
  b = 2
  # Simulate that the assignment is not the method return value but do
  # not add more work to this method
  :noop
end

def parallel_local_assignment
  a, b = 1, 2
  # Simulate that the assignment is not the method return value but do
  # not add more work to this method
  :noop
end

def sequential_block_assignment
  a = nil
  b = nil
  (1..10).each do |x|
    a = b
    b = x
  end
  # Simulate that the assignment is not the method return value but do
  # not add more work to this method
  :noop
end

def parallel_block_assignment
  a = nil
  b = nil
  (1..10).each do |x|
    a, b = b, x
  end
  # Simulate that the assignment is not the method return value but do
  # not add more work to this method
  :noop
end


puts
puts "Ruby #{RUBY_VERSION}"
puts
begin
  require 'benchmark/ips'

  Benchmark.ips do |x|
    x.report('Parallel Local Assignment       ') do
      parallel_local_assignment
    end

    x.report('Sequential Local Assignment     ') do
      sequential_local_assignment
    end

    x.compare!
  end

  Benchmark.ips do |x|
    x.report('Parallel Initialize Assignment  ') do
      parallel_initialize_assignment
    end

    x.report('Sequential Initialize Assignment') do
      sequential_initialize_assignment
    end

    x.compare!
  end

  Benchmark.ips do |x|
    x.report('Parallel Block Assignment       ') do
      parallel_block_assignment
    end

    x.report('Sequential Block Assignment     ') do
      sequential_block_assignment
    end

    x.compare!
  end

rescue LoadError

  # We are on an older Ruby which does not support benchmark/ips
  n = 100_000

  puts "#{n} times"

  Benchmark.benchmark do |bm|
    puts
    puts "Parallel Local Assignment"
    3.times { bm.report { n.times { parallel_local_assignment } } }

    puts
    puts "Sequential Local Assignment"
    3.times { bm.report { n.times { sequential_local_assignment } } }
  end

  Benchmark.benchmark do |bm|
    puts
    puts "Parallel Initialize Assignment"
    3.times { bm.report { n.times { parallel_initialize_assignment } } }

    puts
    puts "Sequential Initialize Assignment"
    3.times { bm.report { n.times { sequential_initialize_assignment } } }
  end

  Benchmark.benchmark do |bm|
    puts
    puts "Parallel Block Assignment"
    3.times { bm.report { n.times { parallel_block_assignment } } }

    puts
    puts "Sequential Block Assignment"
    3.times { bm.report { n.times { sequential_block_assignment } } }
  end
end

__END__

This is a complicated benchmark. Sequential assignment is always faster on Ruby
1.8.7, REE, and JRuby. However, on Ruby 1.9 and 2.x it depends where the
assignment is used - and how many assignments are made.

On Ruby 1.9 and 2.x the assignment of two variable is essentially equally fast
for parallel and sequent. However, as the number of assignments go up parallel
assignment becomes increasingly faster. However, it depends on the context of
that assignment. If the assignment LOC is also an _**implicit**_ return, thus
if it's the last line of a method or a block (this is true for blocks even when
the block return value is ignored), then Ruby will return all variable values
as an array! This array creation is slow and will make sequential assignment
faster, as the incidental array is not created.

Given that there is little benefit for the common case of parallel assignment
for two varaibles, and it's less common to see parallel assignment for three
variables, and extremely rare for any number greater we should default to
sequential assignment. [Aaron Kromer]

Ruby 1.8.7

100000 times

Parallel Local Assignment
  0.080000   0.000000   0.080000 (  0.079573)
  0.060000   0.000000   0.060000 (  0.067334)
  0.060000   0.000000   0.060000 (  0.059873)

Sequential Local Assignment
  0.030000   0.000000   0.030000 (  0.030429)
  0.030000   0.010000   0.040000 (  0.030158)
  0.020000   0.000000   0.020000 (  0.023209)

Parallel Initialize Assignment
  0.090000   0.000000   0.090000 (  0.085544)
  0.080000   0.000000   0.080000 (  0.084318)
  0.080000   0.000000   0.080000 (  0.085762)

Sequential Initialize Assignment
  0.050000   0.000000   0.050000 (  0.048160)
  0.050000   0.000000   0.050000 (  0.049463)
  0.050000   0.000000   0.050000 (  0.051358)

Parallel Block Assignment
  0.460000   0.000000   0.460000 (  0.469698)
  0.460000   0.000000   0.460000 (  0.457632)
  0.450000   0.010000   0.460000 (  0.462481)

Sequential Block Assignment
  0.230000   0.000000   0.230000 (  0.240600)
  0.230000   0.000000   0.230000 (  0.245943)
  0.230000   0.000000   0.230000 (  0.230579)


Ruby 1.9.3

Calculating -------------------------------------
Parallel Local Assignment
                        89.220k i/100ms
Sequential Local Assignment
                        91.383k i/100ms
-------------------------------------------------
Parallel Local Assignment
                          5.075M (± 8.8%) i/s -     25.249M
Sequential Local Assignment
                          5.029M (±12.1%) i/s -     24.673M

Comparison:
Parallel Local Assignment       :  5074905.9 i/s
Sequential Local Assignment     :  5028923.8 i/s - 1.01x slower

Calculating -------------------------------------
Parallel Initialize Assignment
                        61.930k i/100ms
Sequential Initialize Assignment
                        66.286k i/100ms
-------------------------------------------------
Parallel Initialize Assignment
                          1.943M (± 5.3%) i/s -      9.723M
Sequential Initialize Assignment
                          2.124M (± 9.8%) i/s -     10.606M

Comparison:
Sequential Initialize Assignment:  2123826.3 i/s
Parallel Initialize Assignment  :  1943162.0 i/s - 1.09x slower

Calculating -------------------------------------
Parallel Block Assignment
                        30.497k i/100ms
Sequential Block Assignment
                        36.997k i/100ms
-------------------------------------------------
Parallel Block Assignment
                        579.905k (± 7.7%) i/s -      2.897M
Sequential Block Assignment
                        896.073k (± 7.7%) i/s -      4.477M

Comparison:
Sequential Block Assignment     :   896072.9 i/s
Parallel Block Assignment       :   579904.9 i/s - 1.55x slower


Ruby 2.2.2

Calculating -------------------------------------
Parallel Local Assignment
                        83.984k i/100ms
Sequential Local Assignment
                        86.309k i/100ms
-------------------------------------------------
Parallel Local Assignment
                          5.602M (±12.0%) i/s -     27.043M
Sequential Local Assignment
                          5.482M (± 8.0%) i/s -     27.274M

Comparison:
Parallel Local Assignment       :  5602180.9 i/s
Sequential Local Assignment     :  5482370.9 i/s - 1.02x slower

Calculating -------------------------------------
Parallel Initialize Assignment
                        64.000k i/100ms
Sequential Initialize Assignment
                        67.066k i/100ms
-------------------------------------------------
Parallel Initialize Assignment
                          2.044M (± 5.5%) i/s -     10.240M
Sequential Initialize Assignment
                          2.488M (± 6.3%) i/s -     12.407M

Comparison:
Sequential Initialize Assignment:  2487575.1 i/s
Parallel Initialize Assignment  :  2044428.9 i/s - 1.22x slower

Calculating -------------------------------------
Parallel Block Assignment
                        34.362k i/100ms
Sequential Block Assignment
                        45.586k i/100ms
-------------------------------------------------
Parallel Block Assignment
                        593.794k (± 4.5%) i/s -      2.989M
Sequential Block Assignment
                        886.536k (±12.3%) i/s -      4.331M

Comparison:
Sequential Block Assignment     :   886535.9 i/s
Parallel Block Assignment       :   593793.6 i/s - 1.49x slower
