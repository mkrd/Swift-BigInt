//
//  Test_Initialization.swift
//  BigNumberTests
//
//  Created by Marcel Kröker on 23.08.19.
//  Copyright © 2019 Marcel Kröker. All rights reserved.
//

import XCTest
@testable import BigNumber

class Test_Initialization: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Initialization_BInt()
	{
		// Test if BInt stores limbs correctly
		XCTAssert(BInt(limbs: [0]).rawValue.limbs == [0])

		// Test some interesting edge cases
		for n in [0, 1, -1, Int.max, Int.min]
		{
			XCTAssert(n.description == BInt(n).description)
		}

		let b = BInt(1) + BInt(limbs: [UInt64.max, UInt64.max, UInt64.max, UInt64.max])
		XCTAssert(b.rawValue.limbs == [0, 0, 0, 0, 1])
    }
    
    func testUInt8Array()
    {
        // Bytes and expected number
        // 0x0102030405 is 4328719365 in decimal
        let array: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
        let expected: Int = 4328719365
        
        // Init from bytes (array)
        let b = BInt(bytes: array)
        XCTAssertEqual(b.description, expected.description)
        
        // Convert back to bytes
        let bytes = b.getBytes()
        XCTAssertEqual(bytes, array)
    }
    
    func testCodable() {
        for i in 0..<50 {
            let one = BInt(i)
            
            let json = try! JSONEncoder().encode(one)
            
            let my_one = try! JSONDecoder().decode(BInt.self, from: json)
            
            XCTAssertEqual(one, my_one)
            
            let rand = BInt(String(arc4random()), radix: 10)
            
            let rand_json = try! JSONEncoder().encode(rand)
            
            let my_rand = try! JSONDecoder().decode(BInt.self, from: rand_json)
            
            XCTAssertEqual(rand, my_rand)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
