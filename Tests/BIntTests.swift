//
//  BInt.swift
//  BigNumberTests
//
//  Created by Zachary Gorak on 3/2/18.
//  Copyright © 2018 Marcel Kröker. All rights reserved.
//

import XCTest

class BIntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
	
	func testPerformanceStringInit() {
		self.measure {
			for _ in (0...15000) {
				let _ = BInt(String(arc4random()))
			}
		}
	}
	
	func testPerformanceStringRadixInit() {
		self.measure {
			for _ in (0...15000) {
				let _ = BInt(String(arc4random()), radix: 10)
			}
		}
	}
    
}
