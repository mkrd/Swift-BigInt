import XCTest
@testable import BigNumber

class Test_Bitwise_Operations: XCTestCase {

	// MARK: - NOT (~)

	func test_bitwise_not() {
		// BInt uses sign-magnitude NOT: flips bits of each limb individually.
		// Verify basic properties that hold under this model.

		// ~x flips the sign
		let a = BInt(42)
		XCTAssertTrue((~a).isNegative())
		XCTAssertTrue((~BInt(-42)).isPositive())
	}

	// MARK: - AND, OR, XOR on positive values

	func test_bitwise_ops_positive() {
		// BInt bitwise ops work on magnitudes (sign-magnitude representation),
		// not two's complement. Verify against Int for non-negative values.
		let values = [0, 1, 127, 255, 256, 1000, 65535, 0x12345678]

		for a in values {
			for b in values {
				XCTAssertEqual(BInt(a) & BInt(b), BInt(a & b), "\(a) & \(b)")
				XCTAssertEqual(BInt(a) | BInt(b), BInt(a | b), "\(a) | \(b)")
				XCTAssertEqual(BInt(a) ^ BInt(b), BInt(a ^ b), "\(a) ^ \(b)")
			}
		}
	}

	func test_bitwise_identities() {
		// x & 0 == 0
		XCTAssertEqual(BInt(0xDEAD) & BInt(0), BInt(0))
		// x | 0 == x
		XCTAssertEqual(BInt(0xDEAD) | BInt(0), BInt(0xDEAD))
		// x ^ x == 0
		XCTAssertEqual(BInt(0xDEAD) ^ BInt(0xDEAD), BInt(0))
		// x & x == x
		XCTAssertEqual(BInt(0xDEAD) & BInt(0xDEAD), BInt(0xDEAD))
		// x | x == x
		XCTAssertEqual(BInt(0xDEAD) | BInt(0xDEAD), BInt(0xDEAD))
	}

	func test_bitwise_ops_multi_limb() {
		let big1 = BInt(1) << 128 // 2^128
		let big2 = BInt(1) << 64  // 2^64

		// 2^128 & 2^64 == 0 (different bits)
		XCTAssertEqual(big1 & big2, BInt(0))
		// 2^128 | 2^64 == 2^128 + 2^64
		XCTAssertEqual(big1 | big2, big1 + big2)
		// 2^128 ^ 2^128 == 0
		XCTAssertEqual(big1 ^ big1, BInt(0))
		// x ^ 0 == x
		XCTAssertEqual(big1 ^ BInt(0), big1)
		// x & x == x
		XCTAssertEqual(big1 & big1, big1)
		// x | x == x
		XCTAssertEqual(big1 | big1, big1)
	}

	// MARK: - Compound bitwise assignment

	func test_compound_bitwise_assignment() {
		var a = BInt(0xFF)
		a &= BInt(0x0F)
		XCTAssertEqual(a, BInt(0x0F))

		var b = BInt(0xF0)
		b |= BInt(0x0F)
		XCTAssertEqual(b, BInt(0xFF))

		var c = BInt(0xFF)
		c ^= BInt(0xF0)
		XCTAssertEqual(c, BInt(0x0F))
	}

	// MARK: - Shift edge cases

	func test_shift_edge_cases() {
		// Shift by 0
		XCTAssertEqual(BInt(42) << 0, BInt(42))
		XCTAssertEqual(BInt(42) >> 0, BInt(42))

		// Shift zero
		XCTAssertEqual(BInt(0) << 100, BInt(0))
		XCTAssertEqual(BInt(0) >> 100, BInt(0))

		// Large shifts crossing limb boundaries
		let val = BInt(1)
		XCTAssertEqual(val << 128, BInt("340282366920938463463374607431768211456")!)
		XCTAssertEqual((val << 128) >> 128, BInt(1))

		// Compound shift assignment
		var d = BInt(1)
		d <<= 10
		XCTAssertEqual(d, BInt(1024))
		d >>= 5
		XCTAssertEqual(d, BInt(32))
	}
}
