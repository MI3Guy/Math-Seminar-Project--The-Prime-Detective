require "constants.rb"

primes = File.read("primes.txt").split("\n").collect { |n| n.to_i }
composites = File.read("composite.txt").split("\n").collect { |n| n.to_i }

puts "Prime: #{primes.length}, #{primes.length.to_f/(primes.length + composites.length)}"

part_size = MAX_PRIME/20
parts = []
count = 0
primes.each do |p|
	if p > part_size * (parts.length + 1)
		parts << count
		count = 0
	end
	count += 1
end
parts << count
count = 0

p parts
p parts.collect { |x| x.to_f / primes.length }

n = 0
while part_size * (n + 1) > MAX_PRIME
	puts part_size * (n + 1)
	n += 1
end
