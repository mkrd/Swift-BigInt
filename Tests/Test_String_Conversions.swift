//
//  Test_String_Conversions.swift
//  BigNumberTests
//
//  Created by Marcel Kröker on 23.08.19.
//  Copyright © 2019 Marcel Kröker. All rights reserved.
//

import XCTest
@testable import BigNumber

class Test_String_Conversions: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_description_BInt() {
		for n in -4...4
		{
			XCTAssert(n.description == BInt(n).description)
			XCTAssert(n.description == BInt(n.description)!.description)
		}
    }


}
