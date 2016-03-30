import Foundation
import Cocoa

infix operator ^ { associativity left precedence 150 }
func ^(b: Double, e: Int) -> Double
{
	return pow(b, Double(e))
}

func binomial(n: Int, _ k: Int) -> Int
{
	return k == 0 ? 1 : n == 0 ? 0 : binomial(n - 1, k) + binomial(n - 1, k - 1)
}

func kronecker(i: Int, j: Int) -> Int
{
	return i == j ? 1 : 0
}

func numlen(n: Int) -> Int
{
	if n == 0 { return 1 }
	return Int(log10(Double(abs(n)))) + 1
}

func isPrime(n: Int) -> Bool
{
	if n <= 3 { return n > 1 }

	if n % 2 == 0 || n % 3 == 0 { return false }

	var i = 5
	while i * i <= n
	{
		if n % i == 0 || n % (i + 2) == 0
		{
			return false
		}
		i += 6
	}
	return true
}

/**
	Returns the n-th prime number.
*/
func getPrime(n: Int) -> Int
{
	if n < 1 { forceException("There is no 0-th prime number") }

	var prime = 2
	var primeCount = 1

	while primeCount != n
	{
		prime += 1
		if isPrime(prime) { primeCount += 1 }

	}

	return prime
}

/**
	Works with the Sieve of Eratosthenes.
*/
public func primesTo(n: Int) -> [Int]
{
	if n < 2 { return [] }

	var A = BitField(count: n + 1, repeated: true)

	var i = 2
	while i * i <= n
	{
		if A.get(i)
		{
			var j = i * i
			var c = 1
			while j <= n
			{
				A.set(j, b: false)
				j = i * (i + c)
				c += 1
			}
		}
		i += 1
	}

	var res = [2]

	i = 3
	while i <= n
	{
		if A.get(i) { res.append(i) }
		i += 2
	}

	return res
}

// Returns random Int within range
func random(range: Range<Int>) -> Int
{
    let offset = abs(range.startIndex)
    
    let mini = UInt32(range.startIndex + offset)
    let maxi = UInt32(range.endIndex   + offset)
    
    return Int(mini + arc4random_uniform(maxi - mini)) - offset
}

// Returns array filled with n random Ints within range
func random(range: Range<Int>, n: Int) -> [Int]
{
    var res = [Int]()
    for _ in 0..<n
    {
        res.append(random(range))
    }
    return res
}

enum LetterSet
{
	case lowerCase
	case UpperCase
	case Numbers
	case SpecialSymbols
	case All

}

func randomString(length: Int, letterSet: LetterSet...) -> String
{
	var letters = [String]()
	var ranges = [Range<Int>]()

	for ele in letterSet
	{
		switch ele
		{
		case .All:
			ranges.append(33...126)

		case .Numbers:
			ranges.append(48...57)

		case .lowerCase:
			ranges.append(97...122)

		case .UpperCase:
			ranges.append(65...90)

		case .SpecialSymbols:
			ranges += [33...47, 58...64, 91...96, 123...126]
		}
	}

	for range in ranges
	{
		for i in range
		{
			letters.append(String(UnicodeScalar(i)))
		}
	}

	var res = ""

	for _ in 0..<length
	{
		res += letters[random(0..<letters.count)]
	}
	
	return res
} // returns random String with length len

func fibIter(x: Double) -> Double // Iterative Fibonacci
{
    let s5 = sqrt(5.0)
    
    let p1 = 1.0 / s5
    let p2 = (1 + s5) / 2.0
    let p3 = (1 - s5) / 2.0
    
    return p1 * (pow(p2, x) - pow(p3, x))
}


func collatz(n: Int) -> Int
{
	var n = n
    var heap = [0,0]
    
    let s = n
    var runs = 0
    
    while n > 1
    {
        if n < s
        {
            let new = runs + heap[n]
            heap.append(new)
            return new
        }
        
        runs += 1
        
        if n % 2 == 0
        {
            let nn = n / 2
            
            n = nn
        }
        else
        {
            let nn = (3 * n) + 1
            
            n = nn
        }
    }
    
    if heap.count <= s
    {
        heap.append(runs)
    }
    
    return runs
}

func collatzSimple(n: Int) -> Int
{
	var n = n
    var runs = 0

    while n > 1
    {
        runs += 1
        if n % 2 == 0
        {
            let nn = n / 2
            n = nn
        }
        else
        {
            let nn = (3 * n) + 1
            n = nn
        }
    }
    return runs
}

func col(n: Int)
{
	var provenBound = 2 // 4,2,1


	while provenBound < n
	{
		var index = provenBound + 1

		index = (3 * index) + 1
		index >>= 1

		while index > provenBound
		{
			if index & 1 == 0
			{
				index >>= 1
			}
			else
			{
				index = (3 * index) + 1
			}
		}
		provenBound += 2

	}
	print(provenBound)	
}

func monteCarloPi(n: Int) -> Double
{
    var dotsInCircle = 0
    
    for _ in 1...n
    {
        if sqrt(
			pow(  Double(arc4random()) / Double(UINT32_MAX), 2.0)
			+ pow(Double(arc4random()) / Double(UINT32_MAX), 2.0)
			)
			<= 1.0
        {
            dotsInCircle += 1
        }
    }
    
    return (Double(dotsInCircle * 4) / Double(n))
}

func gcd(a: Int, _ b: Int) -> Int
{
    if b == 0 { return a }
    return gcd(b, a % b)
}

func lcm(a: Int, _ b: Int) -> Int
{
    return (a / gcd(a, b)) * b
}
