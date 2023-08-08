//
//  Test_Basic_Math.swift
//  BigNumberTests
//
//  Created by Marcel Kröker on 23.08.19.
//  Copyright © 2019 Marcel Kröker. All rights reserved.
//

import XCTest
#if !COCOAPODS
@testable import MGTools
#endif
@testable import BigNumber

class Test_Basic_Math: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


	func test_Arithmetric_Operators_BInt()
	{
		// Ensure that BInt operators behave like swift operators.
		let iterations = 1_000
		// Get a appropriate maximum number magnitude
		let m = Int(sqrt(Double(iterations))) / 10

		let arithmetricInt:  [(Int,  Int ) -> Int ] = [(+), (-), (*), (/), (%)]
		let arithmetricBInt: [(BInt, BInt) -> BInt] = [(+), (-), (*), (/), (%)]

		for (_, i_op) in (0..<iterations)><(0..<arithmetricInt.count)
		{
			let (x, y) = (math.random((-m)...m), math.random((-m)...m))
			if (i_op > 2 && y == 0) { continue }
			let resInt = (arithmetricInt[i_op])(x, y)
			let resBInt = (arithmetricBInt[i_op])(BInt(x), BInt(y))
			XCTAssert(resInt.description == resBInt.description)
		}
	}

	func test_Comparison_Operators_BInt()
	{
		// Ensure that BInt comparison operators behave like swift operators.
		let iterations = 1_000

		// Get a appropriate maximum number magnitude
		let m = Int(sqrt(Double(iterations))) / 10

		let compareInt:  [(Int,   Int) -> Bool] = [(<), (<=), (>), (>=), (==), (!=)]
		let compareBInt: [(BInt, BInt) -> Bool] = [(<), (<=), (>), (>=), (==), (!=)]

		for (_, i_op) in (0..<iterations)><(0..<compareInt.count)
		{
			let (x, y) = (math.random((-m)...m), math.random((-m)...m))
			let resInt = (compareInt[i_op])(x, y)
			let resBInt = (compareBInt[i_op])(BInt(x), BInt(y))
			XCTAssert(resInt == resBInt)
		}
	}

	func test_Shift_Operators_BInt()
	{
		// Ensure that BInt operators behave like swift operators.
		let iterations = 1_000

		let shiftInt:  [(UInt64,  UInt64) -> UInt64] = [(<<), (>>)]
		let shiftBInt: [(BInt,       Int) -> BInt  ] = [(<<), (>>)]

		for (_, i_op) in (0..<iterations)><(0..<shiftInt.count)
		{
			let (x, y) = (math.random(0...58), math.random(0...58))
			let resInt = (shiftInt[i_op])(UInt64(x), UInt64(y))
			let resBInt = (shiftBInt[i_op])(BInt(x), y)
			XCTAssert(resInt == resBInt)
		}
	}

	func test_Negation_BInt()
	{
		for n in -10...10
		{
			XCTAssert((-n).description == (-BInt(n)).description)
		}
	}

    func test_Addition_BInt() {
		// Edge cases
		var b = BInt(limbs: [UInt64.max, UInt64.max, UInt64.max, UInt64.max]) + BInt(1)
		XCTAssert(b.rawValue.limbs == [0,0,0,0,1])

		b = BInt(limbs: [234234, UInt64.max]) + BInt(limbs: [UInt64.max,0,0,3458235])
		XCTAssert(b.rawValue.limbs == [234233, 0, 1, 3458235])
		XCTAssert(b.description == "21707692919874957951323661576248931189428192643860687825473344249")
    }

	func test_Subtraction_BInt() {
		var b = BInt(limbs: [0,0,0,1]) - BInt(limbs: [0,0,0,0,0,0,1])
		XCTAssert(b.rawValue.limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
		XCTAssert(b.description == "-39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")

		b = -BInt(limbs: [0,0,0,1]) + BInt(limbs: [0,0,0,0,0,0,1])
		XCTAssert(b.rawValue.limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
		XCTAssert(b.description == "39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")


		b = BInt(342564674474362) * BInt(3456293476583265)
		XCTAssert(b.rawValue.limbs == [8710518073375159610, 64184988145])
		XCTAssert(b.description == "1184004049693607094719600751930")

		b = BInt(limbs: [UInt64.max, UInt64.max]) + BInt(limbs: [UInt64.max, UInt64.max])
		XCTAssert( b.rawValue.limbs == [UInt64.max - 1, UInt64.max, 1])


		b = BInt(limbs: [UInt64.max, UInt64.max]) - BInt(limbs: [UInt64.max, UInt64.max])
		XCTAssert( b.rawValue.limbs == [0])
	}

	func test_Multiplication_BInt()
	{
		var b = BInt(limbs: [UInt64.max]) * BInt(limbs: [UInt64.max])
		XCTAssert(b.rawValue.limbs == [1, 18446744073709551614])
		XCTAssert(b.description == "340282366920938463426481119284349108225")

		b = BInt(limbs: [UInt64.max, UInt64.max, UInt64.max]) * BInt(limbs: [UInt64.max, UInt64.max, UInt64.max])
		XCTAssert(b.rawValue.limbs == [1, 0, 0, 18446744073709551614, 18446744073709551615, 18446744073709551615])
		XCTAssert(b.description == "39402006196394479212279040100143613805079739270465446667935739200774948409969539032567850922052710929917699921281025")

		b = BInt(limbs: [UInt64.max]) * BInt(limbs: [1])
		XCTAssert(b.rawValue.limbs == [UInt64.max])
		XCTAssert(b.description == "18446744073709551615")

		b = BInt(Int.max) * BInt(1)
		XCTAssert(b.description == String(Int.max))
		XCTAssert(b.description == "9223372036854775807")
	}

	func test_Factorial_BInt() {
		let b = BInt(85).factorial()
		XCTAssert(b.rawValue.limbs == [
			0x0000000000000000,
			0xb8c394eaa19e0000,
			0x38c8ccdfca313bc3,
			0x1114618c49a52ac4,
			0x0c70dd91509cc80b,
			0x72d84574931b466f,
			0x680a8222a98
		])
		XCTAssert(b.description == "2817104114380550276949479442260611594800"
			+ "566343305742064051019127525600"
			+ "26159795933451040286452340924"
			+ "018275123200000000000000000000")

        XCTAssertEqual(BInt(0).factorial(), BInt(1))
        XCTAssertEqual(BInt(1).factorial(), BInt(1))
        XCTAssertEqual(BInt(2).factorial(), BInt(2))
        XCTAssertEqual(BInt(3).factorial(), BInt(6))
        XCTAssertEqual(BInt(4).factorial(), BInt(24))
        XCTAssertEqual(BInt(99).factorial(), BInt("933262154439441526816992388562667004907159682643816214685929638952175999932299156089414639761565182862536979208272237582511852109168640000000000000000000000"))
	}

	func test_Arithmetric_Operators_BDouble()
	{
		for _ in 0..<1000
		{
			let a = math.random(-10...10)
			let b = math.random(-10...10)
			let c = math.random(-10...10)
			let d = math.random(-10...10)

			if b != 0 && d != 0
			{
				let a1 = BDouble(a, over: b) + BDouble(c, over: d)
				var a1Int = (a * d) + (b * c)
				var under = b * d

				let sign = (a1Int < 0) == (under < 0)

				if sign
				{
					a1Int = abs(a1Int)
					under = abs(under)
				}
				else
				{
					a1Int = -abs(a1Int)
				}

				a1Int = a1Int / math.gcd(abs(a1Int), abs(b * d))
				XCTAssert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
			}

			if b != 0 && d != 0
			{
				let a1 = BDouble(a, over: b) - BDouble(c, over: d)
				var a1Int = (a * d) - (b * c)
				var under = b * d

				let sign = (a1Int < 0) == (under < 0)

				if sign
				{
					a1Int = abs(a1Int)
					under = abs(under)
				}
				else
				{
					a1Int = -abs(a1Int)
				}

				a1Int = a1Int / math.gcd(abs(a1Int), abs(b * d))

				XCTAssert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
			}

			if b != 0 && d != 0
			{
				let a1 = BDouble(a, over: b) * BDouble(c, over: d)
				var a1Int = a * c
				var under = b * d

				let sign = (a1Int < 0) == (under < 0)

				if sign
				{
					a1Int = abs(a1Int)
					under = abs(under)
				}
				else
				{
					a1Int = -abs(a1Int)
				}

				a1Int = a1Int / math.gcd(abs(a1Int), abs(b * d))

				XCTAssert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
			}
		}
	}

    func test_Power() {
        // Reference issue #41
        let TWO : BInt = 2
        let TWO_SIX_THREE : Int = 263
        let TWO_POW_263 : BInt = TWO ** TWO_SIX_THREE
        XCTAssertEqual(TWO_POW_263, BInt("14821387422376473014217086081112052205218558037201992197050570753012880593911808"))
    }
}
