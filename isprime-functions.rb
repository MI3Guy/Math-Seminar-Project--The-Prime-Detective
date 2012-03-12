require "time"
require "constants.rb"

def _isprime(n)
	if n % 2 == 0
		return n == 2
	end
	i = 3
	while i < Math.sqrt(n).floor
		if n % i == 0
			return false
		end
		i += 1
	end
	return true
end
$isprime = lambda { |n| _isprime(n) }

def _isprime_fermat(n, a)
	# Don't use this code for non prime values of a.
	if n % a == 0
		return n == a
	end
	prod = 1
	a2j = a
	d = n - 1
	while d > 0
		if d % 2 != 0
			prod = (prod * a2j) % n
		end
		d = d / 2
		a2j = (a2j*a2j) % n
	end
	if prod != 1
		return false
	end
	return :unknown
end
$isprime_fermat = lambda { |n|
	r = _isprime_fermat(n, 2)
	if r == :unknown
		_isprime_fermat(n, 3)
	else
		r
	end
}
#$isprime_fermat3 = lambda { |n| _isprime_fermat(n, 3) }

def _isprime_euler(n, a)
	# Don't use this code for non prime values of a.
	if n % a == 0
		return n == a
	end
	prod = 1
	a2j = a
	return :unknown if (n - 1) % 2 != 0
	d = (n - 1) / 2
	while d > 0
		if d % 2 != 0
			prod = (prod * a2j) % n
		end
		d = d / 2
		a2j = (a2j*a2j) % n
	end
	if prod.abs != 1
		return a
	end
	if prod != a / n
		return a
	end
	return :unknown
end

$isprime_euler = lambda { |n|
	r = _isprime_euler(n, 2)
	if r == :unknown
		_isprime_euler(n, 3)
	else
		r
	end
}

def _isprime_strongprimetest(n)
	base = [ 2, 3, 5, 7, 11, 13, 17 ]
	limit = [ 2047, 1373653, 25326001, 3215031751, 2152302898747, 3474749660383, 3415500717128321 ]
	if n > limit[-1]
		return :unknown
	end
	d = n - 1
	s = 0
	while d % 2 == 0
		d = d / 2
	end
	d1 = d
	
	0.upto(base.length - 1) do |i|
		a = base[i]
		prod = 1
		a2j = a
		d = d1
		while d > 0
			if d % 2 == 1
				prod = (prod * a2j) % n
			end
			d = d / 2
			a2j = (a2j * a2j) % n
		end
		quitloop = true
		if prod != 1 && prod != n - 1
			(s - 1).times do
				prod = prod*prod % n
				if prod == 1
					return false
				elsif prod == n - 1
					quitloop = false
					break
				end
			end
			if quitloop
				return true
			end
		end
	end
	return false
end
$isprime_strongprimetest = lambda { |n| _isprime_strongprimetest(n) }


def isprimetest(file, &func)
	primes = File.read("primes.txt").split("\n").collect { |n| n.to_i }

	puts "Beginning Search"
	differences = []
=begin
	2.upto(MAX_PRIME) do |n|
		puts "n = #{n}" if n % 10000 == 0
		isPrimeRes = func[n]
		primeListIncludes = primes.include?(n)
		if isPrimeRes != primeListIncludes
			#puts "Difference found"
			differences << n
		end
	end
=end
	puts "End search"

	puts "Beginning Performance test"
	t1 = Time.now
	2.upto(MAX_PRIME) do |n|
		func[n]
	end
	t2 = Time.now
	puts "End Performance test"

	tdiff = t2 - t1

	f = File.open(file + ".log", "w")
	f.puts "Number of differences: #{differences.length}"
	f.puts "Time: #{tdiff}, Average: #{tdiff/(MAX_PRIME-1)}"
	f.puts ""
	f.puts "Differences"
	differences.each do |diff|
		puts diff
	end

	f.flush
	f.close
end

