import XCTest
import Foundation
@testable import BigNumber

class BDoubleTests : XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertNil(BDouble("alphabet"))
		XCTAssertNil(BDouble("-0.123ad2e+123"))
		XCTAssertNil(BDouble("0.123.ad2e123"))
		XCTAssertNil(BDouble("0.123ae123"))
		XCTAssertNil(BDouble("0.123ae1.23"))
		XCTAssertNotNil(BDouble("1.2e+123"))
		XCTAssertNotNil(BDouble("-1.2e+123"))
		XCTAssertNotNil(BDouble("+1.2e-123"))
		XCTAssert(BDouble("0") == 0.0)
		XCTAssert(BDouble("10") == 10.0)
		XCTAssert(BDouble("1.2e10")?.fractionDescription == "120000000000")
		XCTAssert(BDouble("1.2e+10")?.fractionDescription == "120000000000")
		XCTAssert(BDouble("+1.2e+10")?.fractionDescription == "120000000000")
		XCTAssert(BDouble("-1.2e10")?.fractionDescription == "-120000000000")
		XCTAssert(BDouble("1.2")?.fractionDescription == "6/5")
        	XCTAssert(BDouble("ffff",radix:16) == 65535)
        	XCTAssert(BDouble("rfff",radix:16) == nil)
        	XCTAssert(BDouble("ff",radix:10) == nil)
        	XCTAssert(BDouble("255",radix:6) == 597)
        	XCTAssert(BDouble("999",radix:10) == 2457)
		
		for _ in 0..<100 {
			let rn = Double(Double(arc4random()) / Double(UINT32_MAX))
			XCTAssertNotNil(BDouble(rn))
			
			let rn2 = pow(rn * 100, 2.0)
			XCTAssertNotNil(BDouble(rn2))
		}
    }
	
	func testCompare() {
		XCTAssert(BDouble(1.0) == BDouble(1.0))
		XCTAssert(BDouble(1.1) != BDouble(1.0))
		XCTAssert(BDouble(2.0) > BDouble(1.0))
		XCTAssert(BDouble(-1) < BDouble(1.0))
		XCTAssert(BDouble(0.0) <= BDouble(1.0))
		XCTAssert(BDouble(1.1) >= BDouble(1.0))
		
		XCTAssert(1.0 == BDouble(1.0))
		XCTAssert(1.1 != BDouble(1.0))
		XCTAssert(2.0 > BDouble(1.0))
		XCTAssert(0.0 < BDouble(1.0))
		XCTAssert(-1.0 <= BDouble(1.0))
		XCTAssert(1.1 >= BDouble(1.0))
		
		XCTAssert(BDouble(1.0) == 1.0)
		XCTAssert(BDouble(1.1) != 1.0)
		XCTAssert(BDouble(2.0) > 1.0)
		XCTAssert(BDouble(-1) < 1.0)
		XCTAssert(BDouble(0.0) <= 1.0)
		XCTAssert(BDouble(1.1) >= 1.0)
        
        	XCTAssert(BDouble("ff",radix:16) == 255.0)
        	XCTAssert(BDouble("ff",radix:16) != 100.0)
        	XCTAssert(BDouble("ffff",radix:16)! > 255.0)
        	XCTAssert(BDouble("f",radix:16)! < 255.0)
        	XCTAssert(BDouble("0",radix:16)! <= 1.0)
        	XCTAssert(BDouble("f",radix:16)! >= 1.0)
        	XCTAssert(BDouble("44",radix:5) == 68.0)
        	XCTAssert(BDouble("44",radix:5) != 100.0)
        	XCTAssert(BDouble("321",radix:5)! > 255.0)
        	XCTAssert(BDouble("3",radix:5)! < 255.0)
        	XCTAssert(BDouble("0",radix:5)! <= 1.0)
        	XCTAssert(BDouble("4",radix:5)! >= 1.0)
        
		
		for _ in 1..<100 {
			let rn = Double(Double(arc4random()) / Double(UINT32_MAX))
			let rn2 = pow(rn * 100, 2.0)
			
			XCTAssert(BDouble(rn) < BDouble(rn2))
			XCTAssert(BDouble(rn) <= BDouble(rn2))
			XCTAssert(BDouble(rn2) > BDouble(rn))
			XCTAssert(BDouble(rn2) >= BDouble(rn))
			XCTAssert(BDouble(rn) == BDouble(rn))
			XCTAssert(BDouble(rn2) != BDouble(rn))
		}
	}
	
	func testPow() {
		// Test that a number to the zero power is 1
		for i in 0..<100 {
			XCTAssert(pow(BDouble(Double(i)), 0) == 1.0)
			
			let rn = Double(Double(arc4random()) / Double(UINT32_MAX))
			XCTAssert(pow(BDouble(rn), 0) == 1.0)
		}
		
		// Test that a number to the one power is itself
		for i in 0..<100 {
			XCTAssert(pow(BDouble(Double(i)), 1) == Double(i))
			
			let rn = Double(Double(arc4random()) / Double(UINT32_MAX))
			XCTAssert(pow(BDouble(rn), 1) == rn)
		}
	}
	
	func testRounding() {
		XCTAssert(BDouble("-1.0")?.rounded() == BInt("-1"))
		XCTAssert(BDouble("-1.1")?.rounded() == BInt("-1"))
		XCTAssert(BDouble("-1.5")?.rounded() == BInt("-1"))
		XCTAssert(BDouble("-1.6")?.rounded() == BInt("-2"))
		XCTAssert(BDouble("0")?.rounded() == BInt("0"))
		XCTAssert(BDouble("1.0")?.rounded() == BInt("1"))
		XCTAssert(BDouble("1.1")?.rounded() == BInt("1"))
		XCTAssert(BDouble("1.5")?.rounded() == BInt("1"))
		XCTAssert(BDouble("1.6")?.rounded() == BInt("2"))
		
		XCTAssert(floor(BDouble(-1.0)) == BInt("-1"))
		XCTAssert(floor(BDouble(-1.1)) == BInt("-2"))
		XCTAssert(floor(BDouble(-1.5)) == BInt("-2"))
		XCTAssert(floor(BDouble(-1.6)) == BInt("-2"))
		XCTAssert(floor(BDouble(0)) == BInt("0"))
		XCTAssert(floor(BDouble(1.0)) == BInt("1"))
		XCTAssert(floor(BDouble(1.1)) == BInt("1"))
		XCTAssert(floor(BDouble(1.5)) == BInt("1"))
		XCTAssert(floor(BDouble(1.6)) == BInt("1"))
		
		XCTAssert(ceil(BDouble(-1.0)) == BInt("-1"))
		XCTAssert(ceil(BDouble(-1.1)) == BInt("-1"))
		XCTAssert(ceil(BDouble(-1.5)) == BInt("-1"))
		XCTAssert(ceil(BDouble(-1.6)) == BInt("-1"))
		XCTAssert(ceil(BDouble(0)) == BInt("0"))
		XCTAssert(ceil(BDouble(1.0)) == BInt("1"))
		XCTAssert(ceil(BDouble(1.1)) == BInt("2"))
		XCTAssert(ceil(BDouble(1.5)) == BInt("2"))
		XCTAssert(ceil(BDouble(1.6)) == BInt("2"))
	}
	
	func testPrecision() {
		var bigD = BDouble("123456789.123456789")
		bigD?.precision = 2
		XCTAssert(bigD?.decimalDescription == "123456789.12")
		bigD?.precision = 4
		XCTAssert(bigD?.decimalDescription == "123456789.1234")
		bigD?.precision = 10
		XCTAssert(bigD?.decimalDescription == "123456789.1234567890")
		bigD?.precision = 20
		XCTAssert(bigD?.decimalDescription == "123456789.12345678900000000000")
		bigD?.precision = 0
		XCTAssert(bigD?.decimalDescription == "123456789")
		bigD?.precision = -1
		XCTAssert(bigD?.decimalDescription == "123456789")
		bigD?.precision = -100
		XCTAssert(bigD?.decimalDescription == "123456789")
		
		bigD = BDouble("-123456789.123456789")
		bigD?.precision = 2
		XCTAssert(bigD?.decimalDescription == "-123456789.12", (bigD?.decimalDescription)!)
		bigD?.precision = 4
		XCTAssert(bigD?.decimalDescription == "-123456789.1234", (bigD?.decimalDescription)!)
		bigD?.precision = 10
		XCTAssert(bigD?.decimalDescription == "-123456789.1234567890", (bigD?.decimalDescription)!)
		bigD?.precision = 20
		XCTAssert(bigD?.decimalDescription == "-123456789.12345678900000000000")
		bigD?.precision = 0
		XCTAssert(bigD?.decimalDescription == "-123456789")
		bigD?.precision = -1
		XCTAssert(bigD?.decimalDescription == "-123456789")
		bigD?.precision = -100
		XCTAssert(bigD?.decimalDescription == "-123456789")
		
		bigD = BDouble("0.0000000003") // nine zeroes
		bigD?.precision = 0
		XCTAssert(bigD?.decimalDescription == "0.0", (bigD?.decimalDescription)!)
		bigD?.precision = 10
		XCTAssert(bigD?.decimalDescription == "0.0000000003", (bigD?.decimalDescription)!)
		bigD?.precision = 15
		XCTAssert(bigD?.decimalDescription == "0.000000000300000", (bigD?.decimalDescription)!)
		bigD?.precision = 5
		XCTAssert(bigD?.decimalDescription == "0.00000", (bigD?.decimalDescription)!)
	}
	
	func testOperations() {
		XCTAssert(BDouble(1.5) + BDouble(2.0) == BDouble(3.5))
		XCTAssert(BDouble(1.5) - BDouble(2.0) == BDouble(-0.5))
		XCTAssert(BDouble(1.5) * BDouble(2.0) == BDouble(3.0))
		XCTAssert(BDouble(1.0) / BDouble(2.0) == BDouble(0.5))
		XCTAssert(-BDouble(6.54) == BDouble(-6.54))
		testPow()
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
