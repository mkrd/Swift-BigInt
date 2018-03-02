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
	
	func testNearlyEqual() {
		//BDouble.precision = 50
		let BDMax = BDouble(Double.greatestFiniteMagnitude)
		let BDMin = BDouble(Double.leastNormalMagnitude)
		let eFourty = BDouble("0.00000 00000 00000 00000 00000 00000 00000 00001".replacingOccurrences(of: " ", with: ""))!
		
		//print(BDMax.decimalDescription, BDMin.decimalDescription, eFourty.decimalDescription)
		
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100), epsilon: 0.00001))
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100.00000001), epsilon: 0.00001))
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100.0000001), epsilon: 0.00001))
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100.000001), epsilon: 0.00001))
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100.0001), epsilon: 0.00001))
		XCTAssert(BDouble.nearlyEqual(BDouble(100), BDouble(100.001), epsilon: 0.00001))
		XCTAssert(false == BDouble.nearlyEqual(BDouble(100), BDouble(100.01), epsilon: 0.00001))
		XCTAssert(false == BDouble.nearlyEqual(BDouble(100), BDouble(100.1), epsilon: 0.00001))
		XCTAssert(false == BDouble.nearlyEqual(BDouble(100), BDouble(101), epsilon: 0.00001))
		XCTAssert(false == BDouble.nearlyEqual(BDouble(100), BDouble(11), epsilon: 0.00001))
		XCTAssert(false == BDouble.nearlyEqual(BDouble(100), BDouble(1), epsilon: 0.00001))
		
		// Regular large numbers - generally not problematic
		XCTAssert(BDouble.nearlyEqual(BDouble(1000000), BDouble(1000001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(1000001), BDouble(1000000)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(10000), BDouble(10001)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(10001), BDouble(10000)));
		
		// Negative large numbers
		XCTAssert(BDouble.nearlyEqual(BDouble(-1000000), BDouble(-1000001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-1000001), BDouble(-1000000)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(-10000), BDouble(-10001)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(-10001), BDouble(-10000)));
		
		// Numbers around 1
		XCTAssert(BDouble.nearlyEqual(BDouble(1.0000001), BDouble(1.0000002)));
		XCTAssert(BDouble.nearlyEqual(BDouble(1.0000002), BDouble(1.0000001)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(1.0002), BDouble(1.0001)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(1.0001), BDouble(1.0002)));
		
		// Number around -1
		XCTAssert(BDouble.nearlyEqual(BDouble(-1.000001), BDouble(-1.000002)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-1.000002), BDouble(-1.000001)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(-1.0001), BDouble(-1.0002)));
		XCTAssert(false == BDouble.nearlyEqual(BDouble(-1.0002), BDouble(-1.0001)));
		
		// Numbers between 0 and 1
		XCTAssert(BDouble.nearlyEqual(BDouble(0.000000001000001), BDouble(0.000000001000002)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.000000001000002), BDouble(0.000000001000001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.000000000001002), BDouble(0.000000000001001)));
		XCTAssert( BDouble.nearlyEqual(BDouble(0.000000000001001), BDouble(0.000000000001002)));
		
		// Numbers between -1 and 0
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.000000001000001), BDouble(-0.000000001000002)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.000000001000002), BDouble(-0.000000001000001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.000000000001002), BDouble(-0.000000000001001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.000000000001001), BDouble(-0.000000000001002)));
		
		// small difference away from zero
		XCTAssert(BDouble.nearlyEqual(BDouble(0.3), BDouble(0.30000003)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.3), BDouble(-0.30000003)));
		
		// comparisons involving zero
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), BDouble(0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), BDouble(-0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.0), BDouble(-0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.00000001), BDouble(0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), BDouble(0.00000001)));
		XCTAssert(BDouble.nearlyEqual(BDouble(-0.00000001), BDouble(0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), BDouble(-0.00000001)));
		
		XCTAssert(BDouble(0.0) != eFourty)
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), eFourty, epsilon: 0.01));
		XCTAssert(BDouble.nearlyEqual(eFourty, BDouble(0.0), epsilon: 0.01));
		XCTAssert(BDouble.nearlyEqual(eFourty, BDouble(0.0), epsilon: 0.000001));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), eFourty, epsilon: 0.000001));
		
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), -eFourty, epsilon:0.1));
		XCTAssert(BDouble.nearlyEqual(-eFourty, BDouble(0.0), epsilon:0.1));
		XCTAssert(BDouble.nearlyEqual(-eFourty, BDouble(0.0), epsilon: 0.00000001));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), -eFourty, epsilon:0.00000001));
		
		// comparisons involving "extreme" values
		XCTAssert(BDouble.nearlyEqual(BDMax, BDMax));
		XCTAssert(false == BDouble.nearlyEqual(BDMax, -BDMax));
		XCTAssert(false == BDouble.nearlyEqual(-BDMax, BDMax));
		XCTAssert(false == BDouble.nearlyEqual(BDMax, BDMax / 2));
		XCTAssert(false == BDouble.nearlyEqual(BDMax, -BDMax / 2));
		XCTAssert(false == BDouble.nearlyEqual(-BDMax, BDMax / 2));
		
		// comparions very close to zero
		XCTAssert(BDouble.nearlyEqual(BDMin, BDMin));
		XCTAssert(BDouble.nearlyEqual(BDMin, -BDMin));
		XCTAssert(BDouble.nearlyEqual(-BDMin, BDMin));
		XCTAssert(BDouble.nearlyEqual(BDMin, BDouble(0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), BDMin));
		XCTAssert(BDouble.nearlyEqual(-BDMin, BDouble(0.0)));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.0), -BDMin));
		
		XCTAssert(BDouble.nearlyEqual(BDouble(0.000000001), -BDMin));
		XCTAssert(BDouble.nearlyEqual(BDouble(0.000000001), BDMin));
		XCTAssert(BDouble.nearlyEqual(BDMin, BDouble(0.000000001)));
		XCTAssert(BDouble.nearlyEqual(-BDMin, BDouble(0.000000001)));
	}
	
	func testRadix() {
		XCTAssert(BDouble("aa", radix: 16) == 170)
		XCTAssert(BDouble("0xaa", radix: 16) == 170)
		XCTAssert(BDouble("invalid", radix: 16) == nil)
		
		XCTAssert(BDouble("252", radix: 8) == 170)
		XCTAssert(BDouble("0o252", radix: 8) == 170)
		XCTAssert(BDouble("invalid", radix: 8) == nil)
		
		XCTAssert(BDouble("11", radix: 2) == 3)
		XCTAssert(BDouble("0b11", radix: 2) == 3)
		XCTAssert(BDouble("invalid", radix: 2) == nil)
		
		XCTAssert(BDouble("ffff",radix:16) == 65535)
		XCTAssert(BDouble("rfff",radix:16) == nil)
		XCTAssert(BDouble("ff",radix:10) == nil)
		XCTAssert(BDouble("255",radix:6) == 107)
		XCTAssert(BDouble("999",radix:10) == 999)
		XCTAssert(BDouble("ff",radix:16) == 255.0)
		XCTAssert(BDouble("ff",radix:16) != 100.0)
		XCTAssert(BDouble("ffff",radix:16)! > 255.0)
		XCTAssert(BDouble("f",radix:16)! < 255.0)
		XCTAssert(BDouble("0",radix:16)! <= 1.0)
		XCTAssert(BDouble("f",radix:16)! >= 1.0)
		XCTAssert(BDouble("44",radix:5) == 24)
		XCTAssert(BDouble("44",radix:5) != 100.0)
		XCTAssert(BDouble("321",radix:5)! == 86)
		XCTAssert(BDouble("3",radix:5)! < 255.0)
		XCTAssert(BDouble("0",radix:5)! <= 1.0)
		XCTAssert(BDouble("4",radix:5)! >= 1.0)
		XCTAssert(BDouble("923492349",radix:32)! == 9967689075849)
	}
	
	func testOperations() {
		XCTAssert(BDouble(1.5) + BDouble(2.0) == BDouble(3.5))
		XCTAssert(BDouble(1.5) - BDouble(2.0) == BDouble(-0.5))
		XCTAssert(BDouble(1.5) * BDouble(2.0) == BDouble(3.0))
		XCTAssert(BDouble(1.0) / BDouble(2.0) == BDouble(0.5))
		XCTAssert(-BDouble(6.54) == BDouble(-6.54))
		testPow()
	}

    func testPerformanceStringInit() {
        self.measure {
			for _ in (0...1000) {
				let _ = BDouble(String(arc4random()))
				let _ = BDouble(String(arc4random())+"."+String(arc4random()))
			}
        }
    }
	
	func testPerformanceStringRadixInit() {
		self.measure {
			for _ in (0...1000) {
				let _ = BDouble(String(arc4random()), radix: 10)
				let _ = BDouble(String(arc4random())+"."+String(arc4random()), radix: 10)
			}
		}
	}

}
