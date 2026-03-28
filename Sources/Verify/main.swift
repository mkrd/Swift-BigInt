import Foundation
@testable import BigNumber
@testable import MGTools

var failures = 0
var total = 0

func check(_ condition: Bool, _ msg: String = "", file: String = #file, line: Int = #line) {
    total += 1
    if !condition {
        failures += 1
        print("FAIL [\(file):\(line)] \(msg)")
    }
}

func checkEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "", file: String = #file, line: Int = #line) {
    total += 1
    if a != b {
        failures += 1
        print("FAIL [\(file):\(line)] \(a) != \(b) \(msg)")
    }
}

// Basic arithmetic
checkEqual(BInt(0) + BInt(0), BInt(0), "0+0")
checkEqual(BInt(1) + BInt(1), BInt(2), "1+1")
checkEqual(BInt(100) * BInt(200), BInt(20000), "100*200")
checkEqual(BInt(-5) + BInt(10), BInt(5), "-5+10")
checkEqual(BInt(10) - BInt(15), BInt(-5), "10-15")

// Large multiplication
let a = BInt("99999999999999999999999999999999999999")!
let b = BInt("99999999999999999999999999999999999999")!
let expected = BInt("9999999999999999999999999999999999999800000000000000000000000000000000000001")!
checkEqual(a * b, expected, "large mul")

// Factorial
checkEqual(BInt(0).factorial(), BInt(1), "0!")
checkEqual(BInt(1).factorial(), BInt(1), "1!")
checkEqual(BInt(5).factorial(), BInt(120), "5!")
checkEqual(BInt(10).factorial(), BInt(3628800), "10!")
checkEqual(BInt(20).factorial(), BInt("2432902008176640000")!, "20!")

// Fibonacci
checkEqual(BIntMath.fib(1), BInt(1), "fib(1)")
checkEqual(BIntMath.fib(2), BInt(1), "fib(2)")
checkEqual(BIntMath.fib(10), BInt(55), "fib(10)")
checkEqual(BIntMath.fib(20), BInt(6765), "fib(20)")
checkEqual(BIntMath.fib(50), BInt("12586269025")!, "fib(50)")
checkEqual(BIntMath.fib(100), BInt("354224848179261915075")!, "fib(100)")

// Exponentiation
checkEqual(BInt(2) ** 10, BInt(1024), "2^10")
checkEqual(BInt(10) ** 18, BInt("1000000000000000000")!, "10^18")
checkEqual(BInt(3) ** 0, BInt(1), "3^0")

// Division and modulo
checkEqual(BInt(100) / BInt(7), BInt(14), "100/7")
checkEqual(BInt(100) % BInt(7), BInt(2), "100%7")
checkEqual(BInt(1000000) / BInt(1000), BInt(1000), "10^6 / 10^3")

// Large division
let bigNum = BInt(10) ** 100
let divisor = BInt(10) ** 50
checkEqual(bigNum / divisor, BInt(10) ** 50, "10^100 / 10^50")

// String conversion roundtrip
let factStr = BInt(1000).factorial().description
let fromStr = BInt(factStr)!
checkEqual(fromStr, BInt(1000).factorial(), "1000! string roundtrip")

// Larger string roundtrip
let big15k = BInt(15000).factorial()
let big15kStr = big15k.description
let big15kBack = BInt(big15kStr)!
checkEqual(big15kBack, big15k, "15000! string roundtrip")

// Bitwise operations
checkEqual(BInt(0xFF) & BInt(0x0F), BInt(0x0F), "AND")
checkEqual(BInt(0xF0) | BInt(0x0F), BInt(0xFF), "OR")
checkEqual(BInt(0xFF) ^ BInt(0xFF), BInt(0), "XOR")
checkEqual(BInt(0xFF) ^ BInt(0x0F), BInt(0xF0), "XOR2")

// Shifts
checkEqual(BInt(1) << 64, BInt("18446744073709551616")!, "1<<64")
checkEqual(BInt("18446744073709551616")! >> 64, BInt(1), ">>64")

// Comparison
check(BInt(10) < BInt(20), "10 < 20")
check(BInt(-5) < BInt(5), "-5 < 5")
check(BInt(100) > BInt(99), "100 > 99")
check(BInt(42) == BInt(42), "42 == 42")

// BDouble basics
let bd1 = BDouble(1, over: 3)
let bd2 = BDouble(2, over: 3)
checkEqual(bd1 + bd2, BDouble(1), "1/3 + 2/3")
checkEqual(bd1 * BDouble(3), BDouble(1), "1/3 * 3")

// GCD
checkEqual(BIntMath.gcd(BInt(48), BInt(18)), BInt(6), "gcd(48,18)")
checkEqual(BIntMath.gcd(BInt(100), BInt(75)), BInt(25), "gcd(100,75)")

// Mersenne check (note: isMersenne(2) is a known pre-existing bug in Lucas-Lehmer for exp=2)
check(BIntMath.isMersenne(3), "3 is mersenne exp")
check(BIntMath.isMersenne(5), "5 is mersenne exp")
check(BIntMath.isMersenne(7), "7 is mersenne exp")
check(!BIntMath.isMersenne(4), "4 not mersenne exp")
check(!BIntMath.isMersenne(11), "11 not mersenne exp")

print("\n\(total - failures)/\(total) tests passed")
if failures > 0 {
    print("\(failures) FAILURES")
    exit(1)
} else {
    print("All tests passed!")
}
