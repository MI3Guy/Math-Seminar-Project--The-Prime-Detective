#!/usr/bin/env ruby

require "constants.rb"

isPrime = Array.new(MAX_PRIME-1, true)
#isPrime = Array.new(1000000-1, true)

2.upto((isPrime.length + 1) / 2) do |i|
	puts "n = #{i}"
	if isPrime[i - 2]
		j = 2*i
		while j <= isPrime.length + 1
			isPrime[j - 2] = false
			j += i
		end
	end
end

puts "Done. Writing Files."

fPrime = File.open("primes.txt", "w")
fComposite = File.open("composite.txt", "w")
2.upto(isPrime.length + 1) do |i|
	if isPrime[i - 2]
		fPrime.puts i
	else
		fComposite.puts i
	end
end
fPrime.flush
fPrime.close
fComposite.flush
fComposite.close
