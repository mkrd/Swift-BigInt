//
//  BInt Tests.swift
//  MathGround
//
//  Created by Marcel Kröker on 31.01.16.
//  Copyright © 2016 Marcel Kröker. All rights reserved.
//

func testBInt()
{
	// Basic initialization
	var b = BInt(0)
	assert(b.rawData().limbs == [0])
	assert(b.description == "0")

	b = BInt(-0)
	assert(b.rawData().limbs == [0])
	assert(b.description == "0")

	b = BInt(1)
	assert(b.rawData().limbs == [1])
	assert(b.description == "1")

	b = BInt(-1)
	assert(b.rawData().limbs == [1])
	assert(b.description == "-1")

	b = BInt(Int.max)
	assert(b.rawData().limbs == [UInt64(Int.max)])
	assert(b.description == String(Int.max))

	b = BInt(Int.min)
	assert(b.rawData().limbs == [9223372036854775808])
	assert(b.description == String(Int.min))


	// alternating series
	b = BInt(0)
	for k in 0...100
	{
		b += (BInt(-1) ^ k) * (BInt(5) ^ k)
	}
	assert(b.rawData().limbs == [0x28e3f37dc8c26cc9,0x9f59e568b211b961,0xd92c3dea0eea4010,0xf3d659f514])
	assert(b.description == "6573840876841765045097738044023218580610053625908525039752324422200521")

	b = BInt(0)
	for k in 1...138
	{
		b += (BInt(k) ^ k) - (BInt(137) ^ k)
	}
	assert(b.rawData().limbs == [17152098566286916563, 4974948639188066814, 4489317707884913023, 9306023348854241191, 458651883002965321, 3683521711743239055, 16851376351636449383, 741781077320468085, 800339803456222032, 13955889474532705287, 9986965365556055439, 6943506609237153382, 14193507606682829060, 2267111281450088010, 16370502465740827650, 1306853])
	assert(b.description == "12735701500187047591959419733566858766853126946820718978070969024692885331213304930991162556374421032376469699828008508881075741782571348017377682034125474151722103219051041832160135737768757033144950631943320498343308408527570876037282172430879499586152728823468776739519354613957714873403358163")




	// 85 factorial
	b = fact(85)
	assert(b.rawData().limbs == [0x0000000000000000,0xb8c394eaa19e0000,0x38c8ccdfca313bc3,0x1114618c49a52ac4,0x0c70dd91509cc80b,0x72d84574931b466f,0x680a8222a98])
	assert(b.description == "281710411438055027694947944226061159480056634330574206405101912752560026159795933451040286452340924018275123200000000000000000000")


	// Adding

	// Subtracting

	b = BInt(limbs: [0,0,0,1]) - BInt(limbs: [0,0,0,0,0,0,1])
	assert(b.rawData().limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
	assert(b.description == "-39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")

	b = -BInt(limbs: [0,0,0,1]) + BInt(limbs: [0,0,0,0,0,0,1])
	assert(b.rawData().limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
	assert(b.description == "39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")


	b = BInt(342564674474362) * BInt(3456293476583265)
	assert(b.rawData().limbs == [8710518073375159610, 64184988145])
	assert(b.description == "1184004049693607094719600751930")

	b = BInt(limbs: [UInt64.max, UInt64.max]) + BInt(limbs: [UInt64.max, UInt64.max])
	assert( b.rawData().limbs == [UInt64.max - 1, UInt64.max, 1])


	b = BInt(limbs: [UInt64.max, UInt64.max]) - BInt(limbs: [UInt64.max, UInt64.max])
	assert( b.rawData().limbs == [0])



	b = BInt(limbs: [UInt64.max]) * BInt(limbs: [UInt64.max])
	assert(b.rawData().limbs == [1, 18446744073709551614])
	assert(b.description == "340282366920938463426481119284349108225")

	b = BInt(limbs: [UInt64.max, UInt64.max, UInt64.max]) * BInt(limbs: [UInt64.max, UInt64.max, UInt64.max])
	assert(b.rawData().limbs == [1, 0, 0, 18446744073709551614, 18446744073709551615, 18446744073709551615])
	assert(b.description == "39402006196394479212279040100143613805079739270465446667935739200774948409969539032567850922052710929917699921281025")

	b = BInt(limbs: [UInt64.max]) * BInt(limbs: [1])
	assert(b.rawData().limbs == [UInt64.max])
	assert(b.description == "18446744073709551615")

	b = BInt(Int.max) * BInt(1)
	assert(b.description == String(Int.max))
	assert(b.description == "9223372036854775807")

	b = BInt(limbs: [234234, UInt64.max]) + BInt(limbs: [UInt64.max,0,0,3458235])
	assert(b.rawData().limbs == [234233, 0, 1, 3458235])
	assert(b.description == "21707692919874957951323661576248931189428192643860687825473344249")


	// Sign tests
	for i in -10...10
	{
		for j in -10...10
		{
			let IntAdd = i + j
			let IntMul = i * j

			let BIntAdd = BInt(i) + BInt(j)
			let BIntMul = BInt(i) * BInt(j)



			assert(IntAdd == BIntAdd.toInt())
			assert(IntMul == BIntMul.toInt())
		}
	}



	for _ in 0..<100_0
	{
		let a = random(-10...10)
		let b = random(-10...10)

		let p1 = BInt(a) + BInt(b)
		let p2 = -BInt(a) + BInt(b)
		let p3 = BInt(a) + -BInt(b)
		let p4 = -BInt(a) + -BInt(b)
		assert(p1.description == String(a + b))
		assert(p2.description == String(-a + b))
		assert(p3.description == String(a + -b))
		assert(p4.description == String(-a + -b))

		let s1 = BInt(a) - BInt(b)
		let s2 = -BInt(a) - BInt(b)
		let s3 = BInt(a) - -BInt(b)
		let s4 = -BInt(a) - -BInt(b)
		assert(s1.description == String(a - b))
		assert(s2.description == String(-a - b))
		assert(s3.description == String(a - -b))
		assert(s4.description == String(-a - -b))

		let m1 = BInt(a) * BInt(b)
		let m2 = -BInt(a) * BInt(b)
		let m3 = BInt(a) * -BInt(b)
		let m4 = -BInt(a) * -BInt(b)
		assert(m1.description == String(a * b))
		assert(m2.description == String(-a * b))
		assert(m3.description == String(a * -b))
		assert(m4.description == String(-a * -b))

		if b != 0
		{
			let d1 = BInt(a) / BInt(b)
			let d2 = -BInt(a) / BInt(b)
			let d3 = BInt(a) / -BInt(b)
			let d4 = -BInt(a) / -BInt(b)
			assert(d1.description == String(a / b))
			assert(d2.description == String(-a / b))
			assert(d3.description == String(a / -b))
			assert(d4.description == String(-a / -b))
		}

		if b != 0
		{
			let o1 = BInt(a) % BInt(b)
			let o2 = -BInt(a) % BInt(b)
			let o3 = BInt(a) % -BInt(b)
			let o4 = -BInt(a) % -BInt(b)
			assert(o1.description == String(a % b))
			assert(o2.description == String(-a % b))
			assert(o3.description == String(a % -b))
			assert(o4.description == String(-a % -b))
		}

		let l1 = BInt(a) < BInt(b)
		let l2 = -BInt(a) < BInt(b)
		let l3 = BInt(a) < -BInt(b)
		let l4 = -BInt(a) < -BInt(b)
		assert(l1 == (a < b))
		assert(l2 == (-a < b))
		assert(l3 == (a < -b))
		assert(l4 == (-a < -b))
		// <=, >, >=, are based on <, == and != are correct by default
	}



	for _ in 0..<100_0
	{
		let a = random(-10...10)
		let b = random(-10...10)
		let c = random(-10...10)
		let d = random(-10...10)


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

			a1Int = a1Int / gcd(abs(a1Int), abs(b * d))
			assert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
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

			a1Int = a1Int / gcd(abs(a1Int), abs(b * d))

			assert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
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

			a1Int = a1Int / gcd(abs(a1Int), abs(b * d))

			assert(BInt(sign:  a1.sign, limbs: a1.numerator).description == String(a1Int))
		}
	}



	print("All tests passed")
}
