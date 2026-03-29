import XCTest
@testable import BigNumber

class Test_String_Conversions_Extended: XCTestCase {

	// MARK: - BInt description for large values

	func test_description_large_values() {
		// Powers of 10
		XCTAssertEqual((BInt(10) ** 18).description, "1000000000000000000")
		XCTAssertEqual((BInt(10) ** 30).description, "1" + String(repeating: "0", count: 30))

		// Negative large
		XCTAssertEqual((BInt(-1) * BInt(10) ** 18).description, "-1000000000000000000")

		// String roundtrip for wider range
		for n in -500...500 {
			XCTAssertEqual(BInt(n).description, "\(n)")
		}
	}

	// MARK: - BInt string init edge cases

	func test_string_init_edge_cases() {
		// Leading zeros
		XCTAssertEqual(BInt("007"), BInt(7))
		XCTAssertEqual(BInt("0"), BInt(0))
		XCTAssertEqual(BInt("-0"), BInt(0))
		XCTAssertEqual(BInt("00000"), BInt(0))

		// Negative
		XCTAssertEqual(BInt("-42"), BInt(-42))

		// Invalid strings
		XCTAssertNil(BInt("abc"))
		XCTAssertNil(BInt("12.34"))
		XCTAssertNil(BInt("12 34"))
	}

	// MARK: - Radix string conversion roundtrip

	func test_radix_roundtrip() {
		let values = [0, 1, -1, 42, -42, 255, 256, 1000, Int.max, Int.min + 1]
		let bases = [2, 8, 10, 16]

		for val in values {
			for base in bases {
				let b = BInt(val)
				let str = b.asString(radix: base)
				let back = BInt(str, radix: base)
				XCTAssertNotNil(back, "Failed to parse '\(str)' in base \(base)")
				XCTAssertEqual(back, b, "Roundtrip failed for \(val) in base \(base)")
			}
		}
	}

	// MARK: - Hex string with prefix

	func test_hex_string_prefix() {
		XCTAssertEqual(BInt("0xFF", radix: 16), BInt(255))
		XCTAssertEqual(BInt("0o77", radix: 8), BInt(63))
		XCTAssertEqual(BInt("0b1010", radix: 2), BInt(10))
	}

	// MARK: - Very large string roundtrip

	func test_large_factorial_roundtrip() {
		let factorials = [100, 500, 1000, 5000]
		for n in factorials {
			let fac = BInt(n).factorial()
			let str = fac.description
			let back = BInt(str)!
			XCTAssertEqual(back, fac, "\(n)! roundtrip failed")
		}
	}

	// MARK: - Hex string for large numbers

	func test_hex_known_power_of_two() {
		XCTAssertEqual((BInt(1) << 64).asString(radix: 16), "10000000000000000")
		XCTAssertEqual(((BInt(1) << 128) - 1).asString(radix: 16),
			"ffffffffffffffffffffffffffffffff")
		XCTAssertEqual((BInt(1) << 256).asString(radix: 16),
			"1" + String(repeating: "0", count: 64))
	}

	func test_hex_roundtrip_factorial() {
		// Roundtrip 1500! through hex — matches the benchmark
		let fac = BInt(1500).factorial()
		let hex = fac.asString(radix: 16)
		let back = BInt(hex, radix: 16)!
		XCTAssertEqual(back, fac, "1500! hex roundtrip failed")
	}

	func test_hex_vs_decimal_consistency() {
		// Verify hex and decimal representations refer to the same number
		let big = BInt(1000).factorial()
		let fromDec = BInt(big.description)!
		let fromHex = BInt(big.asString(radix: 16), radix: 16)!
		XCTAssertEqual(fromDec, fromHex)
	}

	func test_large_radix_roundtrips() {
		let big = BInt(500).factorial()
		for radix in [2, 8, 16, 32, 36] {
			let str = big.asString(radix: radix)
			let back = BInt(str, radix: radix)!
			XCTAssertEqual(back, big, "500! roundtrip failed for base \(radix)")
		}
	}

	// MARK: - Bytes roundtrip extended

	func test_bytes_roundtrip_extended() {
		// Single byte
		let b1 = BInt(bytes: [0x42])
		XCTAssertEqual(b1, BInt(0x42))
		XCTAssertEqual(b1.getBytes(), [0x42])

		// Multi-byte
		let bytes: Bytes = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
		let b2 = BInt(bytes: bytes)
		XCTAssertEqual(b2, BInt(UInt64.max))

		// Large random roundtrip
		for _ in 0..<20 {
			let numBytes = Int.random(in: 1...32)
			var randomBytes: Bytes = []
			for _ in 0..<numBytes {
				randomBytes.append(UInt8.random(in: 0...255))
			}
			// Strip leading zeros for comparison
			while randomBytes.count > 1 && randomBytes.first == 0 {
				randomBytes.removeFirst()
			}
			let bint = BInt(bytes: randomBytes)
			let result = bint.getBytes()
			XCTAssertEqual(result, randomBytes, "Bytes roundtrip failed")
		}
	}
}
