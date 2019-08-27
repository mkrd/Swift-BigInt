//
//  Test_Initialization.swift
//  BigNumberTests
//
//  Created by Marcel Kröker on 23.08.19.
//  Copyright © 2019 Marcel Kröker. All rights reserved.
//

import XCTest

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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
