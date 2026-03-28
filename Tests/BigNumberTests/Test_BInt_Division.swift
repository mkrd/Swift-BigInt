import XCTest
@testable import BigNumber

class Test_BInt_Division: XCTestCase {

	// MARK: - quotientAndRemainder

	func test_quotientAndRemainder() {
		// Basic positive cases (signs not involved)
		let (q1, r1) = BInt(17).quotientAndRemainder(dividingBy: BInt(5))
		XCTAssertEqual(q1, BInt(3))
		XCTAssertEqual(r1, BInt(2))

		// Exact division
		let (q2, r2) = BInt(100).quotientAndRemainder(dividingBy: BInt(10))
		XCTAssertEqual(q2, BInt(10))
		XCTAssertEqual(r2, BInt(0))

		// Dividend smaller than divisor
		let (q3, r3) = BInt(3).quotientAndRemainder(dividingBy: BInt(7))
		XCTAssertEqual(q3, BInt(0))
		XCTAssertEqual(r3, BInt(3))

		// Large numbers
		let big = BInt(10) ** 50
		let (q4, r4) = big.quotientAndRemainder(dividingBy: BInt(10) ** 25)
		XCTAssertEqual(q4, BInt(10) ** 25)
		XCTAssertEqual(r4, BInt(0))

		// Consistency for all operands: q * divisor + r == dividend
		for _ in 0..<200 {
			let a = BInt(Int.random(in: -10000...10000))
			let b = BInt(Int.random(in: 1...10000)) * (Bool.random() ? 1 : -1)
			let (q, r) = a.quotientAndRemainder(dividingBy: b)
			XCTAssertEqual(q * b + r, a, "\(a) = \(q) * \(b) + \(r)")
		}

		// Verify consistency with / and % operators
		for _ in 0..<200 {
			let a = BInt(Int.random(in: -10000...10000))
			let b = BInt(Int.random(in: 1...10000)) * (Bool.random() ? 1 : -1)
			let (q, r) = a.quotientAndRemainder(dividingBy: b)
			XCTAssertEqual(q, a / b, "quotient mismatch for \(a) / \(b)")
			XCTAssertEqual(r, a % b, "remainder mismatch for \(a) % \(b)")
		}

		// Explicit sign cases
		let (qn1, rn1) = BInt(-17).quotientAndRemainder(dividingBy: BInt(5))
		XCTAssertEqual(qn1, BInt(-3))
		XCTAssertEqual(rn1, BInt(-2))

		let (qn2, rn2) = BInt(17).quotientAndRemainder(dividingBy: BInt(-5))
		XCTAssertEqual(qn2, BInt(-3))
		XCTAssertEqual(rn2, BInt(2))

		let (qn3, rn3) = BInt(-17).quotientAndRemainder(dividingBy: BInt(-5))
		XCTAssertEqual(qn3, BInt(3))
		XCTAssertEqual(rn3, BInt(-2))
	}

	// MARK: - Division with negatives

	func test_division_negative_operands() {
		// BInt uses truncated division: quotient sign = xor of operand signs,
		// remainder sign = dividend sign

		// Negative dividend
		XCTAssertEqual(BInt(-17) / BInt(5), BInt(-3))
		XCTAssertEqual(BInt(-17) % BInt(5), BInt(-2))

		// Negative divisor
		XCTAssertEqual(BInt(17) / BInt(-5), BInt(-3))
		XCTAssertEqual(BInt(17) % BInt(-5), BInt(2))

		// Both negative
		XCTAssertEqual(BInt(-17) / BInt(-5), BInt(3))
		XCTAssertEqual(BInt(-17) % BInt(-5), BInt(-2))

		// Verify: q * b + r == a for all sign combinations
		let cases: [(Int, Int)] = [
			(17, 5), (-17, 5), (17, -5), (-17, -5),
			(100, 7), (-100, 7), (100, -7), (-100, -7),
			(1, 1), (-1, 1), (0, 5), (0, -3),
		]
		for (a, b) in cases {
			let ba = BInt(a), bb = BInt(b)
			let q = ba / bb
			let r = ba % bb
			XCTAssertEqual(q * bb + r, ba, "\(a) / \(b): \(q) * \(b) + \(r) != \(a)")
		}
	}

	// MARK: - Division of zero

	func test_division_zero_dividend() {
		XCTAssertEqual(BInt(0) / BInt(1), BInt(0))
		XCTAssertEqual(BInt(0) / BInt(-1), BInt(0))
		XCTAssertEqual(BInt(0) / BInt(999), BInt(0))
		XCTAssertEqual(BInt(0) % BInt(7), BInt(0))
	}

	// MARK: - Compound assignment operators

	func test_compound_divide_modulo() {
		var a = BInt(100)
		a /= BInt(7)
		XCTAssertEqual(a, BInt(14))

		var b = BInt(100)
		b %= BInt(7)
		XCTAssertEqual(b, BInt(2))

		// Multi-limb
		var c = BInt(10) ** 30
		c /= BInt(10) ** 15
		XCTAssertEqual(c, BInt(10) ** 15)
	}
}
