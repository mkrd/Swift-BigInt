//
//  Test_BIntMath.swift
//  BigNumberTests
//
//  Created by Marcel Kröker on 23.08.19.
//  Copyright © 2019 Marcel Kröker. All rights reserved.
//

import XCTest

class Test_BIntMath: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_gcd()
	{
		for (a, b) in (0...50)><(0...50)
		{
			let steinGCD = BIntMath.gcd(BInt(a), BInt(b))
			let euclidGCD = BIntMath.gcdEuclid(BInt(a), BInt(b))
			XCTAssert(steinGCD == euclidGCD, "SteinGcd does not work")
		}

		let g1 = Storage.readResource("gcdTest1", inBundle: Bundle(for: type(of: self)))
		let g2 = Storage.readResource("gcdTest2", inBundle: Bundle(for: type(of: self)))
		XCTAssert(BIntMath.gcd(BInt(g1)!, BInt(g2)!) == 66)
	}

}
