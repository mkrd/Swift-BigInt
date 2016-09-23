/*
	————————————————————————————————————————————————————————————————————————————
	BInt Tests.swift
	————————————————————————————————————————————————————————————————————————————
	Created by Marcel Kröker on 31.01.16.
	Copyright (c) 2015 Blubyte. All rights reserved.
*/

func testBInt()
{

	// Basic initialization
	var b = BInt(0)
	assert(b.rawValue.limbs == [0])
	assert(b.description == "0")

	b = BInt(-0)
	assert(b.rawValue.limbs == [0])
	assert(b.description == "0")

	b = BInt(1)
	assert(b.rawValue.limbs == [1])
	assert(b.description == "1")

	b = BInt(-1)
	assert(b.rawValue.limbs == [1])
	assert(b.description == "-1")

	b = BInt(Int.max)
	assert(b.rawValue.limbs == [UInt64(Int.max)])
	assert(b.description == String(Int.max))

	b = BInt(Int.min)
	assert(b.rawValue.limbs == [9223372036854775808])
	assert(b.description == String(Int.min))


	// Alternating series
	b = BInt(0)
	for k in 0...100
	{
		b += (BInt(-1) ^ k) * (BInt(5) ^ k)
	}
	assert(b.rawValue.limbs == [0x28e3f37dc8c26cc9,0x9f59e568b211b961,0xd92c3dea0eea4010,0xf3d659f514])
	assert(b.description == "6573840876841765045097738044023218580610053625908525039752324422200521")

	b = BInt(0)
	for k in 1...138
	{
		b += (BInt(k) ^ k) - (BInt(137) ^ k)
	}
	assert(b.rawValue.limbs == [17152098566286916563, 4974948639188066814, 4489317707884913023, 9306023348854241191, 458651883002965321, 3683521711743239055, 16851376351636449383, 741781077320468085, 800339803456222032, 13955889474532705287, 9986965365556055439, 6943506609237153382, 14193507606682829060, 2267111281450088010, 16370502465740827650, 1306853])
	assert(b.description == "12735701500187047591959419733566858766853126946820718978070969024692885331213304930991162556374421032376469699828008508881075741782571348017377682034125474151722103219051041832160135737768757033144950631943320498343308408527570876037282172430879499586152728823468776739519354613957714873403358163")


	// 85 factorial
	b = fact(85)
	assert(b.rawValue.limbs == [0x0000000000000000,0xb8c394eaa19e0000,0x38c8ccdfca313bc3,0x1114618c49a52ac4,0x0c70dd91509cc80b,0x72d84574931b466f,0x680a8222a98])
	assert(b.description == "281710411438055027694947944226061159480056634330574206405101912752560026159795933451040286452340924018275123200000000000000000000")


	// Adding

	b = BInt(1) + BInt(limbs: [UInt64.max, UInt64.max, UInt64.max, UInt64.max])
	assert(b.rawValue.limbs == [0,0,0,0,1])
	b = BInt(limbs: [UInt64.max, UInt64.max, UInt64.max, UInt64.max]) + BInt(1)
	assert(b.rawValue.limbs == [0,0,0,0,1])

	// Subtracting

	b = BInt(limbs: [0,0,0,1]) - BInt(limbs: [0,0,0,0,0,0,1])
	assert(b.rawValue.limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
	assert(b.description == "-39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")

	b = -BInt(limbs: [0,0,0,1]) + BInt(limbs: [0,0,0,0,0,0,1])
	assert(b.rawValue.limbs == [0, 0, 0, 18446744073709551615, 18446744073709551615, 18446744073709551615])
	assert(b.description == "39402006196394479212279040100143613805079739270465446667942016302510335090733374821991058588468813285362163955793920")


	b = BInt(342564674474362) * BInt(3456293476583265)
	assert(b.rawValue.limbs == [8710518073375159610, 64184988145])
	assert(b.description == "1184004049693607094719600751930")

	b = BInt(limbs: [UInt64.max, UInt64.max]) + BInt(limbs: [UInt64.max, UInt64.max])
	assert( b.rawValue.limbs == [UInt64.max - 1, UInt64.max, 1])


	b = BInt(limbs: [UInt64.max, UInt64.max]) - BInt(limbs: [UInt64.max, UInt64.max])
	assert( b.rawValue.limbs == [0])



	b = BInt(limbs: [UInt64.max]) * BInt(limbs: [UInt64.max])
	assert(b.rawValue.limbs == [1, 18446744073709551614])
	assert(b.description == "340282366920938463426481119284349108225")

	b = BInt(limbs: [UInt64.max, UInt64.max, UInt64.max]) * BInt(limbs: [UInt64.max, UInt64.max, UInt64.max])
	assert(b.rawValue.limbs == [1, 0, 0, 18446744073709551614, 18446744073709551615, 18446744073709551615])
	assert(b.description == "39402006196394479212279040100143613805079739270465446667935739200774948409969539032567850922052710929917699921281025")

	b = BInt(limbs: [UInt64.max]) * BInt(limbs: [1])
	assert(b.rawValue.limbs == [UInt64.max])
	assert(b.description == "18446744073709551615")

	b = BInt(Int.max) * BInt(1)
	assert(b.description == String(Int.max))
	assert(b.description == "9223372036854775807")

	b = BInt(limbs: [234234, UInt64.max]) + BInt(limbs: [UInt64.max,0,0,3458235])
	assert(b.rawValue.limbs == [234233, 0, 1, 3458235])
	assert(b.description == "21707692919874957951323661576248931189428192643860687825473344249")

	b = combinations(50_000, 50)
	assert(b.description == "284958500315333290867708487072990268397101930544468658476216100935982755508148971449700622210078705183923286686402942943816349032142836981589618876226813174803825580124000")


	for x in -10...10
	{
		for y in -10...10
		{
			var b1 = BInt(0)
			var b2 = BInt(0)
			var b3 = BInt(0)
			var b4 = BInt(0)

			b1 = BInt(x)
			assert(String(describing: b1) == String(x))

			b1 = -BInt(x)
			assert(String(describing: b1) == String(-x))


			b1 =  BInt(x) +  BInt(y)
			b2 = -BInt(x) +  BInt(y)
			b3 =  BInt(x) + -BInt(y)
			b4 = -BInt(x) + -BInt(y)
			assert(String(describing: b1) == String( x +  y))
			assert(String(describing: b2) == String(-x +  y))
			assert(String(describing: b3) == String( x + -y))
			assert(String(describing: b4) == String(-x + -y))

			b1 =  BInt(x) -  BInt(y)
			b2 = -BInt(x) -  BInt(y)
			b3 =  BInt(x) - -BInt(y)
			b4 = -BInt(x) - -BInt(y)
			assert(String(describing: b1) == String( x -  y))
			assert(String(describing: b2) == String(-x -  y))
			assert(String(describing: b3) == String( x - -y))
			assert(String(describing: b4) == String(-x - -y))

			b1 =  BInt(x) *  BInt(y)
			b2 = -BInt(x) *  BInt(y)
			b3 =  BInt(x) * -BInt(y)
			b4 = -BInt(x) * -BInt(y)
			assert(String(describing: b1) == String( x *  y))
			assert(String(describing: b2) == String(-x *  y))
			assert(String(describing: b3) == String( x * -y))
			assert(String(describing: b4) == String(-x * -y))

			if y != 0
			{
				b1 =  BInt(x) /  BInt(y)
				b2 = -BInt(x) /  BInt(y)
				b3 =  BInt(x) / -BInt(y)
				b4 = -BInt(x) / -BInt(y)
				assert(String(describing: b1) == String( x /  y))
				assert(String(describing: b2) == String(-x /  y))
				assert(String(describing: b3) == String( x / -y))
				assert(String(describing: b4) == String(-x / -y))

				b1 =  BInt(x) %  BInt(y)
				b2 = -BInt(x) %  BInt(y)
				b3 =  BInt(x) % -BInt(y)
				b4 = -BInt(x) % -BInt(y)
				assert(String(describing: b1) == String( x %  y))
				assert(String(describing: b2) == String(-x %  y))
				assert(String(describing: b3) == String( x % -y))
				assert(String(describing: b4) == String(-x % -y))
			}

			var c1 =  BInt(x) <  BInt(y)
			var c2 = -BInt(x) <  BInt(y)
			var c3 =  BInt(x) < -BInt(y)
			var c4 = -BInt(x) < -BInt(y)
			assert(c1 == ( x <  y))
			assert(c2 == (-x <  y))
			assert(c3 == ( x < -y))
			assert(c4 == (-x < -y))

			c1 =  BInt(x) >  BInt(y)
			c2 = -BInt(x) >  BInt(y)
			c3 =  BInt(x) > -BInt(y)
			c4 = -BInt(x) > -BInt(y)
			assert(c1 == ( x >  y))
			assert(c2 == (-x >  y))
			assert(c3 == ( x > -y))
			assert(c4 == (-x > -y))

			c1 =  BInt(x) <=  BInt(y)
			c2 = -BInt(x) <=  BInt(y)
			c3 =  BInt(x) <= -BInt(y)
			c4 = -BInt(x) <= -BInt(y)
			assert(c1 == ( x <=  y))
			assert(c2 == (-x <=  y))
			assert(c3 == ( x <= -y))
			assert(c4 == (-x <= -y))

			c1 =  BInt(x) >=  BInt(y)
			c2 = -BInt(x) >=  BInt(y)
			c3 =  BInt(x) >= -BInt(y)
			c4 = -BInt(x) >= -BInt(y)
			assert(c1 == ( x >=  y))
			assert(c2 == (-x >=  y))
			assert(c3 == ( x >= -y))
			assert(c4 == (-x >= -y))

			c1 =  BInt(x) ==  BInt(y)
			c2 = -BInt(x) ==  BInt(y)
			c3 =  BInt(x) == -BInt(y)
			c4 = -BInt(x) == -BInt(y)
			assert(c1 == ( x ==  y))
			assert(c2 == (-x ==  y))
			assert(c3 == ( x == -y))
			assert(c4 == (-x == -y))

			c1 =  BInt(x) !=  BInt(y)
			c2 = -BInt(x) !=  BInt(y)
			c3 =  BInt(x) != -BInt(y)
			c4 = -BInt(x) != -BInt(y)
			assert(c1 == ( x !=  y))
			assert(c2 == (-x !=  y))
			assert(c3 == ( x != -y))
			assert(c4 == (-x != -y))
			// <=, >, >=, are based on <, == and != are correct by default
		}
	}


	for _ in 0..<100_0
	{
		let a = random(-10..<11)
		let b = random(-10..<11)
		let c = random(-10..<11)
		let d = random(-10..<11)


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
