import XCTest
@testable import BigNumber
#if !COCOAPODS
@testable import MGTools
#endif

class Test_BIntMath_Extended: XCTestCase {

	// MARK: - LCM

	func test_lcm() {
		XCTAssertEqual(BIntMath.lcm(BInt(4), BInt(6)), BInt(12))
		XCTAssertEqual(BIntMath.lcm(BInt(12), BInt(18)), BInt(36))
		XCTAssertEqual(BIntMath.lcm(BInt(7), BInt(13)), BInt(91)) // coprime
		XCTAssertEqual(BIntMath.lcm(BInt(1), BInt(100)), BInt(100))

		// lcm(a,b) * gcd(a,b) == a * b (for positive a,b)
		for _ in 0..<100 {
			let a = BInt(Int.random(in: 1...1000))
			let b = BInt(Int.random(in: 1...1000))
			XCTAssertEqual(
				BIntMath.lcm(a, b) * BIntMath.gcd(a, b),
				a * b,
				"lcm(\(a),\(b)) * gcd(\(a),\(b)) != \(a)*\(b)"
			)
		}
	}

	// MARK: - Permutations & Combinations

	func test_permutations() {
		// P(5, 2) = 5! / 3! = 20
		XCTAssertEqual(BIntMath.permutations(5, 2), BInt(20))
		// P(10, 3) = 10! / 7! = 720
		XCTAssertEqual(BIntMath.permutations(10, 3), BInt(720))
		// P(n, 0) = 1
		XCTAssertEqual(BIntMath.permutations(10, 0), BInt(1))
		// P(n, n) = n!
		XCTAssertEqual(BIntMath.permutations(6, 6), BInt(6).factorial())
	}

	func test_permutationsWithRepetition() {
		// n^k
		XCTAssertEqual(BIntMath.permutationsWithRepitition(2, 3), BInt(8))   // 2^3
		XCTAssertEqual(BIntMath.permutationsWithRepitition(10, 2), BInt(100)) // 10^2
		XCTAssertEqual(BIntMath.permutationsWithRepitition(5, 0), BInt(1))   // n^0
	}

	func test_combinations() {
		// C with repetition (n+k-1)! / (k! * (n-1)!) — this is what the code calls "combinations"
		// For n=5, k=2: (5+2-1)! / (2! * 4!) = 720 / (2*24) = 15
		XCTAssertEqual(BIntMath.combinations(5, 2), BInt(15))
	}

	func test_combinationsWithRepetition() {
		// Standard C(n,k) = n! / (k! * (n-k)!) — this is what the code calls "combinationsWithRepitition"
		// C(5, 2) = 10
		XCTAssertEqual(BIntMath.combinationsWithRepitition(5, 2), BInt(10))
		// C(10, 3) = 120
		XCTAssertEqual(BIntMath.combinationsWithRepitition(10, 3), BInt(120))
		// C(n, 0) = 1
		XCTAssertEqual(BIntMath.combinationsWithRepitition(10, 0), BInt(1))
		// C(n, n) = 1
		XCTAssertEqual(BIntMath.combinationsWithRepitition(5, 5), BInt(1))
	}

	// MARK: - Modular Arithmetic

	func test_mod_exp() {
		// 2^10 mod 1000 = 1024 mod 1000 = 24
		XCTAssertEqual(BIntMath.mod_exp(BInt(2), BInt(10), BInt(1000)), BInt(24))

		// 3^13 mod 7: 3^13 = 1594323, 1594323 mod 7 = 3
		XCTAssertEqual(BIntMath.mod_exp(BInt(3), BInt(13), BInt(7)), BInt(3))

		// Fermat's little theorem: a^(p-1) ≡ 1 (mod p) for prime p, gcd(a,p)=1
		XCTAssertEqual(BIntMath.mod_exp(BInt(2), BInt(12), BInt(13)), BInt(1))
		XCTAssertEqual(BIntMath.mod_exp(BInt(5), BInt(16), BInt(17)), BInt(1))

		// Base case: anything^0 mod m = 1
		XCTAssertEqual(BIntMath.mod_exp(BInt(999), BInt(0), BInt(7)), BInt(1))

		// Large modular exponentiation
		let result = BIntMath.mod_exp(BInt(2), BInt(256), BInt("1000000007")!)
		// 2^256 mod 10^9+7
		let expected = (BInt(2) ** 256) % BInt("1000000007")!
		XCTAssertEqual(result, expected)

		// Verify consistency: mod_exp(b, p, m) == (b ** p) % m for small values
		for _ in 0..<100 {
			let base = BInt(Int.random(in: 1...20))
			let exp = BInt(Int.random(in: 0...15))
			let mod = BInt(Int.random(in: 2...100))
			let fast = BIntMath.mod_exp(base, exp, mod)
			let naive = (base ** Int(exp.asInt()!)) % mod
			XCTAssertEqual(fast, naive, "mod_exp(\(base), \(exp), \(mod))")
		}
	}

	func test_nnmod() {
		// Non-negative modulo: result is always in [0, |m|)
		XCTAssertEqual(BIntMath.nnmod(BInt(7), BInt(5)), BInt(2))
		XCTAssertEqual(BIntMath.nnmod(BInt(-7), BInt(5)), BInt(3))  // -7 % 5 = -2, + 5 = 3
		XCTAssertEqual(BIntMath.nnmod(BInt(-1), BInt(10)), BInt(9))
		XCTAssertEqual(BIntMath.nnmod(BInt(0), BInt(5)), BInt(0))
		XCTAssertEqual(BIntMath.nnmod(BInt(10), BInt(10)), BInt(0))

		// Result is always non-negative
		for _ in 0..<100 {
			let a = BInt(Int.random(in: -1000...1000))
			let m = BInt(Int.random(in: 1...100))
			let result = BIntMath.nnmod(a, m)
			XCTAssertTrue(result >= BInt(0), "nnmod(\(a), \(m)) = \(result) should be >= 0")
			XCTAssertTrue(result < m, "nnmod(\(a), \(m)) = \(result) should be < \(m)")
		}
	}

	func test_mod_add() {
		// mod_add(a, b, m) == nnmod(a + b, m)
		XCTAssertEqual(BIntMath.mod_add(BInt(7), BInt(8), BInt(10)), BInt(5))
		XCTAssertEqual(BIntMath.mod_add(BInt(-3), BInt(1), BInt(5)), BInt(3))

		for _ in 0..<100 {
			let a = BInt(Int.random(in: -1000...1000))
			let b = BInt(Int.random(in: -1000...1000))
			let m = BInt(Int.random(in: 1...100))
			XCTAssertEqual(
				BIntMath.mod_add(a, b, m),
				BIntMath.nnmod(a + b, m),
				"mod_add(\(a), \(b), \(m))"
			)
		}
	}

	// MARK: - isPrime

	func test_isPrime() {
		let math = BIntMath()
		let knownPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
		for p in knownPrimes {
			XCTAssertTrue(math.isPrime(BInt(p)), "\(p) should be prime")
		}

		let nonPrimes = [0, 1, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 25, 100]
		for n in nonPrimes {
			XCTAssertFalse(math.isPrime(BInt(n)), "\(n) should not be prime")
		}

		// Larger primes
		XCTAssertTrue(math.isPrime(BInt(104729)))  // 10000th prime
		XCTAssertFalse(math.isPrime(BInt(104730)))
	}

	// MARK: - Fibonacci edge cases

	func test_fib_known_values() {
		XCTAssertEqual(BIntMath.fib(2), BInt(1))
		XCTAssertEqual(BIntMath.fib(3), BInt(2))
		XCTAssertEqual(BIntMath.fib(10), BInt(55))
		XCTAssertEqual(BIntMath.fib(20), BInt(6765))
		XCTAssertEqual(BIntMath.fib(50), BInt("12586269025")!)

		// Verify fib(n) = fib(n-1) + fib(n-2) for a range
		for n in 4...30 {
			XCTAssertEqual(
				BIntMath.fib(n),
				BIntMath.fib(n - 1) + BIntMath.fib(n - 2),
				"fib(\(n)) != fib(\(n-1)) + fib(\(n-2))"
			)
		}
	}

	func test_fib_large_recurrence() {
		// F(n) = F(n-1) + F(n-2) for larger values
		for n in [100, 500, 1000, 5000] {
			XCTAssertEqual(
				BIntMath.fib(n),
				BIntMath.fib(n - 1) + BIntMath.fib(n - 2),
				"fib(\(n)) != fib(\(n-1)) + fib(\(n-2))"
			)
		}
	}

	func test_fib_larger_known_values() {
		XCTAssertEqual(BIntMath.fib(100), BInt("354224848179261915075")!)
		XCTAssertEqual(BIntMath.fib(300), BInt("222232244629420445529739893461909967206666939096499764990979600")!)

		// fib(1000): verify via recurrence and digit count
		let f1000 = BIntMath.fib(1000)
		XCTAssertEqual(f1000.description.count, 209)
		XCTAssert(f1000.description.hasPrefix("4346655768693745643568852767"))
		XCTAssertEqual(f1000, BIntMath.fib(999) + BIntMath.fib(998))
	}

	func test_fib_lucas_identity() {
		// F(2k) = F(k) * [2*F(k+1) - F(k)]
		for k in [50, 200, 500, 1000] {
			let f2k = BIntMath.fib(2 * k)
			let fk = BIntMath.fib(k)
			let fk1 = BIntMath.fib(k + 1)
			XCTAssertEqual(f2k, fk * (BInt(2) * fk1 - fk),
				"Lucas identity failed for k=\(k)")
		}
	}

	func test_fib_100000_spot_check() {
		let f = BIntMath.fib(100_000)
		// Known digit count
		XCTAssertEqual(f.description.count, 20899)
		// Known prefix
		XCTAssert(f.description.hasPrefix("2597406934722"))
		// Recurrence: F(100000) = F(99999) + F(99998)
		XCTAssertEqual(f, BIntMath.fib(99_999) + BIntMath.fib(99_998))
	}

	// MARK: - Mersenne

	func test_isMersenne() {
		// Known Mersenne prime exponents (small ones)
		let mersenneExponents = [3, 5, 7, 13, 17, 19, 31]
		for exp in mersenneExponents {
			XCTAssertTrue(BIntMath.isMersenne(exp), "2^\(exp)-1 should be Mersenne prime")
		}

		// Known non-Mersenne exponents
		let nonMersenne = [4, 6, 8, 9, 10, 11, 12, 14, 15, 16, 18, 20, 23]
		for exp in nonMersenne {
			XCTAssertFalse(BIntMath.isMersenne(exp), "2^\(exp)-1 should NOT be Mersenne prime")
		}
	}

	// MARK: - GCD edge cases

	func test_gcd_edge_cases() {
		// gcd(0, 0) = 0
		XCTAssertEqual(BIntMath.gcd(BInt(0), BInt(0)), BInt(0))
		// gcd(n, 0) = n
		XCTAssertEqual(BIntMath.gcd(BInt(42), BInt(0)), BInt(42))
		// gcd(0, n) = n
		XCTAssertEqual(BIntMath.gcd(BInt(0), BInt(42)), BInt(42))
		// gcd(n, n) = n
		XCTAssertEqual(BIntMath.gcd(BInt(17), BInt(17)), BInt(17))
		// gcd(1, n) = 1
		XCTAssertEqual(BIntMath.gcd(BInt(1), BInt(999)), BInt(1))

		// Large coprime numbers
		XCTAssertEqual(BIntMath.gcd(BInt(10) ** 20, BInt(10) ** 20 + 1), BInt(1))
	}
}
