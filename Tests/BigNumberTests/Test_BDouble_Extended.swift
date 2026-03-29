import XCTest
@testable import BigNumber

class Test_BDouble_Extended: XCTestCase {

	// MARK: - Division

	func test_division() {
		let a = BDouble(1, over: 2)
		let b = BDouble(1, over: 3)
		// (1/2) / (1/3) = 3/2
		XCTAssertEqual(a / b, BDouble(3, over: 2))

		// Division by 1
		XCTAssertEqual(BDouble(42) / BDouble(1), BDouble(42))

		// Division producing whole number
		XCTAssertEqual(BDouble(6) / BDouble(3), BDouble(2))

		// Negative division
		XCTAssertEqual(BDouble(-10) / BDouble(2), BDouble(-5))
		XCTAssertEqual(BDouble(10) / BDouble(-2), BDouble(-5))
		XCTAssertEqual(BDouble(-10) / BDouble(-2), BDouble(5))
	}

	// MARK: - Subtraction edge cases

	func test_subtraction() {
		// Same value
		XCTAssertEqual(BDouble(42) - BDouble(42), BDouble(0))

		// Fractions
		let a = BDouble(5, over: 6)
		let b = BDouble(1, over: 6)
		XCTAssertEqual(a - b, BDouble(2, over: 3))

		// Result crossing zero
		XCTAssertEqual(BDouble(1) - BDouble(3), BDouble(-2))
	}

	// MARK: - abs

	func test_abs() {
		XCTAssertEqual(abs(BDouble(5)), BDouble(5))
		XCTAssertEqual(abs(BDouble(-5)), BDouble(5))
		XCTAssertEqual(abs(BDouble(0)), BDouble(0))
		XCTAssertEqual(abs(BDouble(-1, over: 3)), BDouble(1, over: 3))
	}

	// MARK: - floor / ceil

	func test_floor_ceil() {
		// Positive fractions
		XCTAssertEqual(floor(BDouble(7, over: 2)), BInt(3))   // 3.5 -> 3
		XCTAssertEqual(ceil(BDouble(7, over: 2)), BInt(4))    // 3.5 -> 4

		// Exact integers
		XCTAssertEqual(floor(BDouble(4)), BInt(4))
		XCTAssertEqual(ceil(BDouble(4)), BInt(4))

		// Negative fractions
		XCTAssertEqual(floor(BDouble(-7, over: 2)), BInt(-4))  // -3.5 -> -4
		XCTAssertEqual(ceil(BDouble(-7, over: 2)), BInt(-3))   // -3.5 -> -3

		// Zero
		XCTAssertEqual(floor(BDouble(0)), BInt(0))
		XCTAssertEqual(ceil(BDouble(0)), BInt(0))
	}

	// MARK: - min / max

	func test_min_max() {
		let a = BDouble(1, over: 3)
		let b = BDouble(1, over: 2)

		XCTAssertEqual(min(a, b), a)
		XCTAssertEqual(max(a, b), b)

		// Same values
		XCTAssertEqual(min(a, a), a)
		XCTAssertEqual(max(a, a), a)

		// Negative
		let c = BDouble(-5)
		let d = BDouble(3)
		XCTAssertEqual(min(c, d), c)
		XCTAssertEqual(max(c, d), d)
	}

	// MARK: - BDouble with BInt interop

	func test_bdouble_bint_interop() {
		let d = BDouble(BInt(42))
		XCTAssertEqual(d, BDouble(42))

		// Arithmetic with BInt
		let sum = BDouble(1, over: 2) + BDouble(BInt(1))
		XCTAssertEqual(sum, BDouble(3, over: 2))
	}

	// MARK: - Fraction minimization

	func test_minimize() {
		// 2/4 should minimize to 1/2
		let a = BDouble(2, over: 4)
		let b = BDouble(1, over: 2)
		XCTAssertEqual(a, b)

		// 100/200 == 1/2
		XCTAssertEqual(BDouble(100, over: 200), BDouble(1, over: 2))

		// Already minimal
		XCTAssertEqual(BDouble(3, over: 7), BDouble(3, over: 7))

		// Large fraction that reduces
		let large = BDouble(BInt(1000000), over: BInt(2000000))
		XCTAssertEqual(large, BDouble(1, over: 2))
	}

	// MARK: - Modulo

	func test_modulo() {
		// 7.5 % 2.5 = 0
		let a = BDouble(15, over: 2)
		let b = BDouble(5, over: 2)
		XCTAssertEqual(a % b, BDouble(0))

		// 10 % 3 = 1
		XCTAssertEqual(BDouble(10) % BDouble(3), BDouble(1))

		// Fractional modulo
		// 5/3 % 1/2 = 5/3 - 3*(1/2) = 5/3 - 3/2 = 10/6 - 9/6 = 1/6
		XCTAssertEqual(BDouble(5, over: 3) % BDouble(1, over: 2), BDouble(1, over: 6))
	}

	// MARK: - Decimal expansion edge cases

	func test_decimal_expansion_negative() {
		let neg = BDouble(-1, over: 3)
		let str = neg.decimalExpansion(precisionAfterDecimalPoint: 5, rounded: false)
		XCTAssertEqual(str, "-0.33333")
	}

	func test_decimal_expansion_whole_number() {
		let whole = BDouble(42)
		let str = whole.decimalExpansion(precisionAfterDecimalPoint: 3, rounded: false)
		XCTAssertEqual(str, "42.000")
	}

	func test_decimal_expansion_zero() {
		let z = BDouble(0)
		let str = z.decimalExpansion(precisionAfterDecimalPoint: 4, rounded: false)
		XCTAssertEqual(str, "0.0000")
	}

	func test_decimal_expansion_repeating_pattern() {
		// 1/7 = 0.142857142857... (period 6)
		let val = BDouble(1, over: 7)
		let expansion = val.decimalExpansion(precisionAfterDecimalPoint: 6000, rounded: false)
		let digits = String(expansion.dropFirst(2)) // drop "0."
		XCTAssertEqual(digits.count, 6000)

		let period = "142857"
		for i in stride(from: 0, to: digits.count - 5, by: 6) {
			let start = digits.index(digits.startIndex, offsetBy: i)
			let end = digits.index(start, offsetBy: 6)
			XCTAssertEqual(String(digits[start..<end]), period,
				"1/7 period mismatch at position \(i)")
		}
	}

	func test_decimal_expansion_1_over_3() {
		let val = BDouble(1, over: 3)
		let expansion = val.decimalExpansion(precisionAfterDecimalPoint: 5000, rounded: false)
		let digits = String(expansion.dropFirst(2))
		XCTAssert(digits.allSatisfy({ $0 == "3" }), "1/3 should be all 3s")
	}
}
