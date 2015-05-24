require 'benchmark/ips'

def use_map_and_array_bracket(input)
  input.map { |v| v.to_s }
end

def use_inject(input)
  input.inject([]) do |array, v|
    array << v.to_s
    array
  end
end

[10, 100, 1000].each do |size|
  array = 1.upto(size)
  unless use_map_and_array_bracket(array) == use_inject(array)
    raise "Not the same!"
  end

  puts
  puts "A array of #{size}"

  Benchmark.ips do |x|
    x.report("Use map and Array[]") { use_map_and_array_bracket(array) }
    x.report("Use inject") { use_inject(array) }
    x.compare!
  end
end

__END__

`inject` appears to be slightly slower.

A array of 10
Calculating -------------------------------------
 Use map and Array[]    35.749k i/100ms
          Use inject    32.590k i/100ms
-------------------------------------------------
 Use map and Array[]    445.509k (± 3.4%) i/s -      2.252M
          Use inject    400.561k (± 3.1%) i/s -      2.021M

Comparison:
 Use map and Array[]:   445509.2 i/s
          Use inject:   400560.8 i/s - 1.11x slower


A array of 100
Calculating -------------------------------------
 Use map and Array[]     5.556k i/100ms
          Use inject     4.972k i/100ms
-------------------------------------------------
 Use map and Array[]     57.508k (± 3.8%) i/s -    288.912k
          Use inject     51.280k (± 3.0%) i/s -    258.544k

Comparison:
 Use map and Array[]:    57508.0 i/s
          Use inject:    51279.8 i/s - 1.12x slower


A array of 1000
Calculating -------------------------------------
 Use map and Array[]   576.000  i/100ms
          Use inject   516.000  i/100ms
-------------------------------------------------
 Use map and Array[]      5.679k (± 4.6%) i/s -     28.800k
          Use inject      4.820k (± 8.2%) i/s -     24.252k

Comparison:
 Use map and Array[]:     5678.9 i/s
          Use inject:     4819.5 i/s - 1.18x slower