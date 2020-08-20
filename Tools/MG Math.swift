/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Basic Math.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 03.04.2015.
*   Copyright © 2015 Marcel Kröker. All rights reserved.
*/

#if os(Linux)
	import Glibc
	import CBSD
#endif

import Foundation

infix operator **

func **(lhs: Double, rhs: Double) -> Double { return pow(lhs, rhs) }
func **(lhs: Int, rhs: Double) -> Double { return pow(Double(lhs), rhs) }
func **(lhs: Double, rhs: Int) -> Double { return pow(lhs, Double(rhs)) }
func **(lhs: Int, rhs: Int) -> Int
{
	var res = 1
	for _ in 0..<rhs { res *= lhs }
	return res
}

/*	Automatic type inference for operators that operate on Int and Double,
 *	use Double as the resulting type.
 */

func +(lhs: Double, rhs: Int) -> Double { return lhs + Double(rhs) }
func +(lhs: Int, rhs: Double) -> Double { return Double(lhs) + rhs }

func -(lhs: Double, rhs: Int) -> Double { return lhs - Double(rhs) }
func -(lhs: Int, rhs: Double) -> Double { return Double(lhs) - rhs }

func *(lhs: Double, rhs: Int) -> Double { return lhs * Double(rhs) }
func *(lhs: Int, rhs: Double) -> Double { return Double(lhs) * rhs }

func /(lhs: Double, rhs: Int) -> Double { return lhs / Double(rhs) }
func /(lhs: Int, rhs: Double) -> Double { return Double(lhs) / rhs }



public class math
{
	init()
	{
		fatalError("math is purely static, you can't make an instance of it.")
	}

	/// Returns the logarithm of n to the base of b.
	public static func lg(base b: Double, _ n: Double) -> Double
	{
		return log2(Double(n)) / log2(Double(b))
	}

	/// Returns the logarithm of n to the base of b.
	public static func lg(base b: Int, _ n: Double) -> Double
	{
		return math.lg(base: Double(b), n)
	}

	/// Returns the logarithm of n to the base of b.
	public static func lg(base b: Double, _ n: Int) -> Double
	{
		return math.lg(base: b, Double(n))
	}

	/// Returns the logarithm of n to the base of b.
	public static func lg(base b: Int, _ n: Int) -> Double
	{
		return math.lg(base: Double(b), Double(n))
	}


	/// Returns the binomial coefficient of n and k.
	public static func binomial(_ n: Int, _ k: Int) -> Int
	{
		if k == 0 { return 1 }
		if n == 0 { return 0 }
		return math.binomial(n - 1, k) + math.binomial(n - 1, k - 1)
	}

	/// Returns the greatest common divisor of a and b.
	public static func gcd(_ a: Int, _ b: Int) -> Int
	{
		if b == 0 { return a }
		return math.gcd(b, a % b)
	}

	/// Returns the lest common multiple of a and b.
	public static func lcm(_ a: Int, _ b: Int) -> Int
	{
		return (a / math.gcd(a, b)) * b
	}

	/**
	 *	Returns the number of digits of the input in the specified base.
	 *	Positive and negative numbers are treated equally.
	 */
	public static func digitsCount(base b: Int, _ n: Int) -> Int
	{
		var n = abs(n)
		var count = 0

		while n != 0
		{
			n /= b
			count += 1
		}

		return count
	}

	// Returns true iff n is a prime number.
	public static func isPrime(_ n: Int) -> Bool
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

	/// Returns the n-th prime number. The first one is 2, etc.
	public static func getPrime(_ n: Int) -> Int
	{
		precondition(n > 0, "There is no \(n)-th prime number")

		var (prime, primeCount) = (2, 1)

		while primeCount != n
		{
			prime += 1
			if math.isPrime(prime) { primeCount += 1 }
		}

		return prime
	}



	/// Returns all primes that are smaller or equal to n. Works with the Sieve of Eratosthenes.
    public static func primesThrough(_ n: Int) -> [Int]
    {
        if n <  2 { return [] }
        
        // represent numbers 3,5,... that are <= n
        var A = [Bool](repeating: true, count: n >> 1)
        
        var (i, j, c) = (3, 0, 0)
        while i * i <= n
        {
            if A[(i >> 1) - 1]
            {
                (c, j) = (1, i * i)
                while j <= n
                {
                    if j % 2 != 0 { A[(j >> 1) - 1] = false }
                    j = i * (i + c)
                    c += 1
                }
            }
            i += 2
        }
        
        var res = [2]

		i = 3
		while i <= n
		{
			if A[(i >> 1) - 1] { res.append(i) }
			i += 2
		}

        return res
    }
    

	/// Increments the input parameter until it is the next bigger prime.
	public static func nextPrime( _ n: inout Int)
	{
		repeat { n += 1 } while !math.isPrime(n)
	}

	/// Returns a random integer within the specified range. The maximum range size is 2**32 - 1
	public static func random(_ range: Range<Int>) -> Int
	{
		let offset = Int(range.lowerBound)
		let delta = UInt32(range.upperBound - range.lowerBound)

		return offset + Int(arc4random_uniform(delta))
	}

	/// Returns a random integer within the specified closed range.
	public static func random(_ range: ClosedRange<Int>) -> Int
	{
		return math.random(Range(range))
	}

	/// Returns an array filled with n random integers within the specified range.
	public static func random(_ range: Range<Int>, count: Int) -> [Int]
	{
		return [Int](repeating: 0, count: count).map{ _ in math.random(range) }
	}

	/// Returns an array filled with n random integers within the specified closed range.
	public static func random(_ range: ClosedRange<Int>, count: Int) -> [Int]
	{
		return math.random(Range(range), count: count)
	}

	/// Returns a random Double within the specified closed range.
	public static func random(_ range: ClosedRange<Double>) -> Double
	{
		let offset = range.lowerBound
		let delta = range.upperBound - range.lowerBound

		return offset + ((delta * Double(arc4random())) / Double(UInt32.max))
	}

	/// Returns an array filled with n random Doubles within the specified closed range.
	public static func random(_ range: ClosedRange<Double>, count: Int) -> [Double]
	{
		return [Double](repeating: 0, count: count).map{ _ in math.random(range) }
	}

	/// Calculate a random value from a standard normal distribution with mean 0 and variance 1.
	public static func randomStandardNormalDistributed() -> Double
	{
		var (x, y, l) = (0.0, 0.0, 0.0)

		while l >= 1.0 || l == 0.0
		{
			x = math.random(-1.0...1.0)
			y = math.random(-1.0...1.0)
			l = pow(x, 2.0) + pow(y, 2.0)
		}

		return y * sqrt((-2.0 * log(l)) / l)
	}


	/// Generate count many random values from a normal distribution with the given mean and variance.
	public static func randomFromNormalDist(_ mean: Double, _ variance: Double, _ count: Int) -> [Double]
	{
		let res = [Double](repeating: mean, count: count)

		return res.map{ $0 + (variance * math.randomStandardNormalDistributed())
		}
	}

	/// Multiple cases to select the instance space of a random string.
	public enum LetterSet
	{
		case lowerCase
		case upperCase
		case numbers
		case specialSymbols
		case all
	}

	/**
	Creates a random String from one or multiple sets of
	letters.

	- Parameter length: Number of characters in random string.

	- Parameter letterSet: Specify desired letters as variadic
	parameters:
	- .All
	- .Numbers
	- .LowerCase
	- .UpperCase
	- .SpecialSymbols
	*/
	public static func randomString(_ length: Int, letterSet: LetterSet...) -> String
	{
		var letters = [String]()
		var ranges = [CountableClosedRange<Int>]()

		for ele in letterSet
		{
			switch ele
			{
			case .all:
				ranges.append(33...126)

			case .numbers:
				ranges.append(48...57)

			case .lowerCase:
				ranges.append(97...122)

			case .upperCase:
				ranges.append(65...90)

			case .specialSymbols:
				ranges += [33...47, 58...64, 91...96, 123...126]
			}
		}

		for range in ranges
		{
			for symbol in range
			{
				letters.append(String(describing: UnicodeScalar(symbol)!))
			}
		}

		var res = ""

		for _ in 0..<length
		{
			res.append(letters[math.random(0..<letters.count)])
		}

		return res
	}

	/// Factorize a number n into its prime factors.
	public static func factorize(_ n: Int) -> [(factor: Int, count: Int)]
	{
		if math.isPrime(n) || n == 1 { return [(n, 1)] }

		var n = n
		var res = [(factor: Int, count: Int)]()
		var nthPrime = 1

		while true
		{
			math.nextPrime(&nthPrime)

			if n % nthPrime == 0
			{
				var times = 1
				n /= nthPrime
				
				while n % nthPrime == 0
				{
					times += 1
					n /= nthPrime
				}
				
				res.append((nthPrime, times))
				
				if n == 1 { return res }
				
				if math.isPrime(n)
				{
					res.append((n, 1))
					return res
				}
			}
		}
	}
}
