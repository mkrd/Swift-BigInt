import XCTest
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

    func testCreation() {
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
    }
	
	func testPow() {
		// Test that a number to the zero power is 1
		for i in 0..<100 {
			XCTAssert(pow(BDouble(Double(i)), 0) == 1.0)
		}
		
		// Test that a number to the one power is itself
		for i in 0..<100 {
			XCTAssert(pow(BDouble(Double(i)), 1) == Double(i))
		}
	}
	
	func testPrecision() {
		var bigD = BDouble("123456789.123456789")
		bigD?.precision = 2
		XCTAssert(bigD?.decimalDescription == "123456789.12")
		bigD?.precision = 4
		XCTAssert(bigD?.decimalDescription == "123456789.1234")
		bigD?.precision = 10
		XCTAssert(bigD?.decimalDescription == "123456789.1234567890")
		bigD?.precision = 0
		XCTAssert(bigD?.decimalDescription == "123456789")
		bigD?.precision = -1
		XCTAssert(bigD?.decimalDescription == "123456789")
		bigD?.precision = -100
		XCTAssert(bigD?.decimalDescription == "123456789")
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
