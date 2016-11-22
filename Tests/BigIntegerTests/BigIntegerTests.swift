import XCTest
@testable import BigInteger

/// number of iterations for tests
fileprivate let nTests = 2

class BigIntegerTests: XCTestCase {
    func testBaseConversions() {
        testBaseConversion(iterations: nTests)
        XCTAssert(true)
    }


    func testBIntRandoms() {
        testBIntRandom(iterations: nTests)
        XCTAssert(true)
    }

    func testBInts() {
        testBInt()
        XCTAssert(true)
    }

    func testPerformanceBInt() {
        self.measure {
            benchmarkBInt()
        }
    }

    static var allTests : [(String, (BigIntegerTests) -> () throws -> Void)] {
        return [
            ("testBaseConversions", testBaseConversions),
            ("testBIntRandoms",     testBIntRandoms),
            ("testBInts",           testBInts),
            ("testPerformanceBInt", testPerformanceBInt),
        ]
    }
}
