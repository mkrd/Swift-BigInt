import XCTest
@testable import BigNumber

class Test_BInt_Properties: XCTestCase {

	// MARK: - Status methods

	func test_isZero() {
		XCTAssertTrue(BInt(0).isZero())
		XCTAssertFalse(BInt(1).isZero())
		XCTAssertFalse(BInt(-1).isZero())
		XCTAssertTrue((BInt(5) - BInt(5)).isZero())
	}

	func test_isPositive_isNegative() {
		XCTAssertTrue(BInt(1).isPositive())
		XCTAssertFalse(BInt(1).isNegative())

		XCTAssertTrue(BInt(-1).isNegative())
		XCTAssertFalse(BInt(-1).isPositive())

		// Zero is positive (sign == false)
		XCTAssertTrue(BInt(0).isPositive())
		XCTAssertFalse(BInt(0).isNegative())
	}

	func test_isOdd_isEven() {
		for i in -20...20 {
			let b = BInt(i)
			if i % 2 == 0 {
				XCTAssertTrue(b.isEven(), "\(i) should be even")
				XCTAssertFalse(b.isOdd(), "\(i) should not be odd")
			} else {
				XCTAssertTrue(b.isOdd(), "\(i) should be odd")
				XCTAssertFalse(b.isEven(), "\(i) should not be even")
			}
		}

		// Large numbers
		let bigEven = BInt(2) ** 100
		XCTAssertTrue(bigEven.isEven())
		XCTAssertFalse(bigEven.isOdd())

		let bigOdd = (BInt(2) ** 100) + 1
		XCTAssertTrue(bigOdd.isOdd())
		XCTAssertFalse(bigOdd.isEven())
	}

	func test_signum() {
		XCTAssertEqual(BInt(42).signum(), BInt(1))
		XCTAssertEqual(BInt(-42).signum(), BInt(-1))
		XCTAssertEqual(BInt(0).signum(), BInt(0))
	}

	// MARK: - asInt

	func test_asInt() {
		for i in -100...100 {
			XCTAssertEqual(BInt(i).asInt(), i)
		}
		XCTAssertEqual(BInt(Int.max).asInt(), Int.max)
		XCTAssertEqual(BInt(Int.min).asInt(), Int.min)

		// Too large for Int => nil
		XCTAssertNil((BInt(Int.max) + 1).asInt())
		XCTAssertNil((BInt(Int.min) - 1).asInt())

		// Multi-limb => nil
		XCTAssertNil((BInt(1) << 128).asInt())
	}

	// MARK: - magnitude

	func test_magnitude() {
		XCTAssertEqual(BInt(5).magnitude, BInt(5))
		XCTAssertEqual(BInt(-5).magnitude, BInt(5))
		XCTAssertEqual(BInt(0).magnitude, BInt(0))

		let big = BInt(-1) * (BInt(10) ** 50)
		XCTAssertEqual(big.magnitude, BInt(10) ** 50)
	}

	// MARK: - negate

	func test_negate() {
		var a = BInt(42)
		a.negate()
		XCTAssertEqual(a, BInt(-42))
		a.negate()
		XCTAssertEqual(a, BInt(42))

		// Negating zero stays zero
		var zero = BInt(0)
		zero.negate()
		XCTAssertEqual(zero, BInt(0))
		XCTAssertTrue(zero.isPositive()) // sign should remain false
	}

	// MARK: - Compound arithmetic assignment

	func test_compound_arithmetic() {
		var a = BInt(10)
		a += BInt(5)
		XCTAssertEqual(a, BInt(15))

		a -= BInt(20)
		XCTAssertEqual(a, BInt(-5))

		a *= BInt(-3)
		XCTAssertEqual(a, BInt(15))

		a *= BInt(0)
		XCTAssertEqual(a, BInt(0))
	}

	// MARK: - Int.min special case roundtrip

	func test_int_min_roundtrip() {
		let b = BInt(Int.min)
		XCTAssertEqual(b.asInt(), Int.min)
		XCTAssertEqual(b.description, Int.min.description)
		XCTAssertTrue(b.isNegative())
	}
}
