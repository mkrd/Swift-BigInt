//
//  BInt.swift
//  BigNumberTests
//
//  Created by Zachary Gorak on 3/2/18.
//  Copyright © 2018 Marcel Kröker. All rights reserved.
//

import XCTest
#if !COCOAPODS
import MGTools
#endif
@testable import BigNumber

class BIntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testRadixInitializerAndGetter()
	{
		let chars: [Character] = [
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g",
			"h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
			"y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
			"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
		]
        
		// Randomly choose two bases and a number length, as well as a sign (+ or -)
		for _ in 0..<100
		{
			let fromBase = math.random(2...62)
			let toBase = math.random(2...62)
			let numLength = math.random(1...100)
			let sign = math.random(0...1) == 1 ? "-" : ""

			// First digit should not be a 0.
			var num = sign + String(chars[math.random(1..<fromBase)])

			for _ in 1..<numLength
			{
				num.append(chars[math.random(0..<fromBase)])
			}

			// Convert the random number to a BInt type
			let b1 = BInt(num, radix: fromBase)
			// Get the number as a string with the second base
			let s1 = b1!.asString(radix: toBase)
			// Convert that number to a BInt type
			let b2 = BInt(s1, radix: toBase)
			// Get the number back as as string in the start base
			let s2 = b2!.asString(radix: fromBase)

			XCTAssert(b1 == b2)
			XCTAssert(s2 == num)
		}

		let bigHex = "abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef00"
		let x = BInt(bigHex, radix: 16)!
		XCTAssert(x.asString(radix: 16) == bigHex)
	}


	func testRadix() {
		XCTAssert(BInt("ffff",radix:16) == 65535)
		XCTAssert(BInt("ff",radix:16) == 255.0)
		XCTAssert(BInt("ff",radix:16) != 100.0)
		XCTAssert(BInt("ffff",radix:16)! > 255.0)
		XCTAssert(BInt("f",radix:16)! < 255.0)
		XCTAssert(BInt("0",radix:16)! <= 1.0)
		XCTAssert(BInt("f", radix: 16)! >= 1.0)
		XCTAssert(BInt("rfff",radix:16) == nil)
		
		XCTAssert(BInt("ffff",radix:16) == 65535)
		XCTAssert(BInt("rfff",radix:16) == nil)
		XCTAssert(BInt("ff",radix:10) == nil)
		XCTAssert(BInt("255",radix:6) == 107)
		XCTAssert(BInt("999",radix:10) == 999)
		XCTAssert(BInt("ff",radix:16) == 255.0)
		XCTAssert(BInt("ff",radix:16) != 100.0)
		XCTAssert(BInt("ffff",radix:16)! > 255.0)
		XCTAssert(BInt("f",radix:16)! < 255.0)
		XCTAssert(BInt("0",radix:16)! <= 1.0)
		XCTAssert(BInt("f",radix:16)! >= 1.0)
		XCTAssert(BInt("44",radix:5) == 24)
		XCTAssert(BInt("44",radix:5) != 100.0)
		XCTAssert(BInt("321",radix:5)! == 86)
		XCTAssert(BInt("3",radix:5)! < 255.0)
		XCTAssert(BInt("0",radix:5)! <= 1.0)
		XCTAssert(BInt("4",radix:5)! >= 1.0)
		XCTAssert(BInt("923492349",radix:32)! == 9967689075849)
	}
    
    func testIntInit() {
        XCTAssert(BInt(UInt64.max) == UInt64.max)
        XCTAssert(BInt(Int64.max) == Int64.max)
        XCTAssert(BInt(Int64.min) == Int64.min)
        XCTAssert(BInt(UInt32.max) == UInt32.max)
        XCTAssert(BInt(Int32.max) == Int32.max)
        XCTAssert(BInt(Int32.min) == Int32.min)
        XCTAssert(BInt(UInt16.max) == UInt16.max)
        XCTAssert(BInt(Int16.max) == Int16.max)
        XCTAssert(BInt(Int16.min) == Int16.min)
        XCTAssert(BInt(UInt64.max) == UInt64.max)
        XCTAssert(BInt(Int8.max) == Int8.max)
        XCTAssert(BInt(Int8.min) == Int8.min)
        XCTAssert(BInt(UInt.max) == UInt.max)
        XCTAssert(BInt(Int.max) == Int.max)
        XCTAssert(BInt(Int.min) == Int.min)
    }
    
    func testNotEqual() {
        XCTAssert(BInt(Int64.max) != Int64.min)
        XCTAssert(BInt(Int64.max) != 0)
        XCTAssert(BInt(Int64.min) != Int64.max)
        XCTAssert(BInt(Int64.min) != 0)
        XCTAssert(BInt(Int32.max) != Int32.min)
        XCTAssert(BInt(Int32.max) != 0)
        XCTAssert(BInt(Int32.min) != Int32.max)
        XCTAssert(BInt(Int32.min) != 0)
        XCTAssert(BInt(Int16.max) != Int16.min)
        XCTAssert(BInt(Int16.max) != 0)
        XCTAssert(BInt(Int16.min) != Int16.max)
        XCTAssert(BInt(Int16.min) != 0)
        XCTAssert(BInt(Int8.max) != Int8.min)
        XCTAssert(BInt(Int8.max) != 0)
        XCTAssert(BInt(Int8.min) != Int8.max)
        XCTAssert(BInt(Int8.min) != 0)
        XCTAssert(BInt(Int.max) != Int.min)
        XCTAssert(BInt(Int.max) != 0)
        XCTAssert(BInt(Int.min) != Int.max)
        XCTAssert(BInt(Int.min) != 0)
    }
	
	func testPerformanceStringInit() {
		self.measure {
			for _ in (0...15000) {
				let _ = BInt(String(UInt32.random(in: 0..<UInt32.max)))
			}
		}
	}
	
	func testPerformanceStringRadixInit() {
		self.measure {
			for _ in (0...15000) {
				let _ = BInt(String(UInt32.random(in: 0..<UInt32.max)), radix: 10)
			}
		}
	}
    
    /** An issue was reported where a hex string was not being converted to a decimal. This test case checks that. */
    func testIssue58() throws {
        // 190000000000000000000
        let x = try XCTUnwrap(BInt("0x00000000000000000000000000000000000000000000000a4cc799563c380000", radix: 16))
        let y = try XCTUnwrap(BInt("0x00000000000000000000000000000000000000000000000a4cc799563c380000", radix: 16))
        XCTAssertEqual(x, y)
        for radix in 2...16 {
            XCTAssertEqual(x.asString(radix: radix), y.asString(radix: radix))
        }
        XCTAssertNotEqual(x, 0)
        XCTAssertGreaterThan(x, BInt(Int32.max))
        XCTAssertEqual(x, BInt("190000000000000000000"))
    }
    
    func testIssue67() throws {
        let x = try XCTUnwrap(BInt("0b1310c5a2c30000", radix: 16))
        XCTAssertEqual(x, BInt("0x0b1310c5a2c30000", radix: 16))
        
        let y = try XCTUnwrap(BInt("0b", radix: 16))
        XCTAssertEqual(y, 11)
        XCTAssertEqual(y, BInt("0xb", radix: 16))
        XCTAssertEqual(y, BInt("0x0b", radix: 16))
    }
}
