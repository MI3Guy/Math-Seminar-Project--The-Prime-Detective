require "rubygems"
require "time"
require "bsearch"
require "constants.rb"


def _isprime(n)
	if n % 2 == 0
		return [n == 2, 0]
	end
	i = 3
	while i <= Math.sqrt(n).floor
		if n % i == 0
			return [false, 0]
		end
		i += 1
	end
	return [true, 1]
end
$isprime = lambda { |n| _isprime(n) }

def _isprime_fermat(n, a)
	# Don't use this code for non prime values of a.
	if n % a == 0
		return [n == a, :error]
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
		return [false, a]
	end
	return [:unknown, 0]
end
$isprime_fermat = lambda { |n|
	r = _isprime_fermat(n, 2)
	if r[0] == :unknown
		_isprime_fermat(n, 3)
	else
		r
	end
}
#$isprime_fermat3 = lambda { |n| _isprime_fermat(n, 3) }

def _jacobis_number(d, n)
	d1 = d
	n1 = n.abs
	m = 0
	n8 = n1 % 8
	if n8 % 2 == 0
		return 0
	end
	if d1 < 0
		d1 = -d1
		m = m + 1 if n8 == 3 || n8 == 7
	end
	while true
		if d1 == 0
			return 0
		end
		i2 = 0
		u = d1 / 2
		if d1 == u*2
			i2 = i2 + 1
			d1 = u
		end
		if i2 % 2 != 0
			m = m + (n8*n8 - 1) / 8
		end
		u4 = d1 % 4
		m = m + (n8 - 1) * (u4 - 1) / 4
		z = n1 % d1
		n1 = d1
		d1 = z
		n8 = n1 % 8
		if n1 > 1
			next
		end
		m = m % 2
		if m == 0
			return 1
		else
			return -1
		end
		break
	end
end

def _isprime_euler(n, a)
	# Don't use this code for non prime values of a.
	if n % a == 0
		return [n == a, :error]
	end
	prod = 1
	a2j = a
	return [:unknown, :error] if (n - 1) % 2 != 0
	d = (n - 1) / 2
	while d > 0
		if d % 2 != 0
			prod = (prod * a2j) % n
		end
		d = d / 2
		a2j = (a2j*a2j) % n
	end
	if prod != 1 && prod != n - 1
		#return a
		return [false, a]
	end
	j = _jacobis_number(a, n)
	if !(j == 1 && prod == 1) && !(j == -1 && prod == n - 1)
		#puts _jacobis_number(a, n)
		#return a
		return [false, a]
	end
	return [:unknown, 0]
end

$isprime_euler = lambda { |n|
	r = _isprime_euler(n, 2)
	if r[0] == :unknown
		_isprime_euler(n, 3)
	else
		r
	end
}

def _isprime_strongprimetest(n)
	base = [ 2, 3, 5, 7, 11, 13, 17 ]
	limit = [ 2047, 1373653, 25326001, 3215031751, 2152302898747, 3474749660383, 3415500717128321 ]
	if n > limit[-1]
		return [:unknown, :error]
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
					return [false, 0]
				elsif prod == n - 1
					quitloop = false
					break
				end
			end
			if quitloop
				return [true, 0]
			end
		end
	end
	return [false, 0]
end
$isprime_strongprimetest = lambda { |n| _isprime_strongprimetest(n) }


def isprimetest(file, &func)
	primes = File.read("primes.txt").split("\n").collect { |n| n.to_i }

	puts "Beginning Search"
	differences = []
	categories = Hash.new
	2.upto(MAX_PRIME) do |n|
		#puts "n=#{n}"
		isPrimeRes = func[n]
		primeListIncludes = primes.bsearch_first { |x| x <=> n }
		if isPrimeRes[0]
			if !primeListIncludes
				differences << [n, isPrimeRes[0]]
			end
		else
			if !categories[isPrimeRes[1]]
				categories[isPrimeRes[1]] = 1
			else
				categories[isPrimeRes[1]] += 1
			end
			if primeListIncludes
				differences << [n, isPrimeRes[0]]
			end
		end
	end
	puts "End search"

	puts "Beginning Performance test"
	timediffs = []
	10.times do
		t1 = Time.now
		2.upto(MAX_PRIME) do |n|
			func[n]
		end
		t2 = Time.now
		timediffs << (t2 - t1)
	end
	puts "End Performance test"

	f = File.open(file + ".log", "w")
	f.puts "Number of differences: #{differences.length}"
	f.puts "Times"
	timediffs.each do |t|
		f.puts t
	end
	f.puts ""
	f.puts "Differences"
	differences.each do |diff|
		f.puts diff
	end
	f.puts ""
	f.puts "Categories"
	categories.each_pair do |k,x|
		f.puts "#{k}=#{x}"
	end

	f.flush
	f.close
end

