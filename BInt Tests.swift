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

	print("All tests passed")
}
