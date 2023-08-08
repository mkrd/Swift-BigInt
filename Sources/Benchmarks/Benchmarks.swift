/*
*   ————————————————————————————————————————————————————————————————————————————
*   Benchmarks.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 05.09.17.
*   Copyright © 2017 Marcel Kröker. All rights reserved.
*/

import Foundation
@testable import BigNumber
@testable import MGTools

public class Benchmarks
{
	static func Matrix1()
	{
		let A = Matrix<BDouble>(
			[[2,5,-2],
			 [3,5,6],
			 [-55,4,3]]
		)

		let G12 = Matrix<BDouble>([
			[0.8,	-0.6,	0.0],
			[0.6,	0.8,	0.0],
			[0.0,	0.0,	1.0]
		])


		let al = Matrix<BDouble>([4, -3, 1])

		print(G12 * al)

		let (L, R, P, D) = LRDecompPivEquil(A)

		print(solveGauss(A, [2.0, -4.0, 15.0]))
		print(solveLR(A, [2.0, -4.0, 15.0]))
		print(solveLRPD(A, [2.0, -4.0, 15.0]))

		print("P L R")
		print(P)
		print(L)
		print(R)

		print("LR == PDA")
		print(L * R)
		print(P * D * A)


		benchmarkAndPrint(title: "Matix ^ 100")
		{
			var R = A
			for _ in 0...100
			{
				R = R * A
			}
		}
	}

	static func BDoubleConverging()
	{
		benchmarkAndPrint(title: "BDouble converging to 2")
		{
			// BDouble converging to 2 Debug Mode
			// 06.02.16: 3351ms

			var res: BDouble = 0
			var den: BInt = 1

			for _ in 0..<1000
			{
				res = res + BDouble(BInt(1), over: den)
				den *= 2
			}
		}
	}

	static func factorial()
	{
		let n = 25_000

		benchmarkAndPrint(title: "Factorial of 25000")
		{
			// Fkt 1000  Debug Mode
			// 27.01.16: 2548ms
			// 30.01.16: 1707ms
			// 01.02.16: 398ms

			// Fkt 2000  Debug Mode
			// 01.02.16: 2452ms
			// 04.02.16: 2708ms
			// 06.02.16: 328ms

			// Factorial 4000  Debug Mode
			// 06.02.16: 2669ms
			// 10.02.16: 571ms
			// 28.02.16: 550ms
			// 01.03.16: 56ms

			// Factorial 25000  Debug Mode
			// 01.03.16: 2871ms
			// 07.03.16: 2221ms
			// 16.08.16: 1759ms
			// 20.08.16: 1367ms
			// 23.08.19: 1075ms
			_ = BInt(n).factorial()
		}
	}

	static func exponentiation()
	{
		let n = 10
		let pow = 120_000

		benchmarkAndPrint(title: "10^120_000")
		{
			// 10^14000 Debug Mode
			// 06.02.16: 2668ms
			// 10.02.16: 372ms
			// 20.02.16: 320ms
			// 28.02.16: 209ms
			// 01.03.16: 39ms

			// 10^120_000 Debug Mode
			// 01.03.16: 2417ms
			// 07.03.16: 1626ms
			// 16.08.16: 1154ms
			// 20.08.16: 922ms
			// 23.08.19: 710ms

			_ = BInt(n) ** pow
		}
	}

	static func fibonacci()
	{
		let n = 100_000

		benchmarkAndPrint(title: "Fib \(n)")
		{
			// Fib 35.000 Debug Mode
			// 27.01.16: 2488ms
			// 30.01.16: 1458ms
			// 01.02.16: 357ms

			// Fib 100.000 Debug Mode
			// 01.02.16: 2733ms
			// 04.02.16: 2949ms
			// 10.02.16: 1919ms
			// 28.02.16: 1786ms
			// 07.03.16: 1716ms
			// 23.08.19: 1124ms

			_ = BIntMath.fib(n)
		}
	}

	static func mersennes()
	{
		let n = 256

		benchmarkAndPrint(title: "\nMersennes to 2^\(n)")
		{
			// Mersenne to exp 256 Debug Mode
			// 02.10.16: 1814ms

			for i in 1...n
			{
				if math.isPrime(i) && BIntMath.isMersenne(i)
				{
					print(i, terminator: ",")
				}
			}

		}
	}

	static func BIntToString()
	{
		let factorialBase = 15_000
		let n = BInt(factorialBase).factorial()
		benchmarkAndPrint(title: "Get \(factorialBase)! as String")
		{
			// Get 300! (615 decimal digits) as String Debug Mode
			// 30.01.16: 2635ms
			// 01.02.16: 3723ms
			// 04.02.16: 2492m
			// 06.02.16: 2326ms
			// 07.02.16: 53ms

			// Get 1000! (2568 decimal digits) as String Debug Mode
			// 07.02.16: 2386ms
			// 10.02.16: 343ms
			// 20.02.16: 338ms
			// 22.02.16: 159ms

			// Get 3000! (9131 decimal digits) as String Debug Mode
			// 22.02.16: 2061ms
			// 28.02.16: 1891ms
			// 01.03.16: 343ms

			// Get 7500! (25809 decimal digits) as String Debug Mode
			// 01.03.16: 2558ms
			// 07.03.16: 1604ms
			// 07.03.16: 1562ms
			// 16.08.16: 455ms

			// Get 15000! (56130 decimal digits) as String Debug Mode
			// 07.09.17: 2701ms

			_ = n.description
		}
	}

	static func StringToBInt()
	{
		let factorialBase = 16_000
		let asStr = BInt(factorialBase).factorial().description
		var res: BInt = 0

		benchmarkAndPrint(title: "BInt from String, \(asStr.count) digits (\(factorialBase)!)")
		{
			// BInt from String, 3026 digits (1151!) Debug Mode
			// 07.02.16: 2780ms
			// 10.02.16: 1135ms
			// 28.02.16: 1078ms
			// 01.03.16: 430ms

			// BInt from String, 9131 digits (3000!) Debug Mode
			// 01.03.16: 3469ms
			// 07.03.16: 2305ms
			// 07.03.16: 1972ms
			// 26.06.16: 644ms

			// BInt from String, 20066 digits (6000!) Debug Mode
			// 26.06.16: 3040ms
			// 16.08.16: 2684ms
			// 20.08.16: 2338ms

			// BInt from String, 60320 digits (16000!) Debug Mode
			// 07.09.17: 2857ms
			// 26.04.18: 1081ms

			res = BInt(asStr)!
		}

		assert(asStr == res.description)
	}

	static func permutationsAndCombinations()
	{
		benchmarkAndPrint(title: "Perm and Comb")
		{
			// Perm and Comb (2000, 1000) Debug Mode
			// 04.02.16: 2561ms
			// 06.02.16: 2098ms
			// 07.02.16: 1083ms
			// 10.02.16: 350ms
			// 28.02.16: 337ms
			// 01.03.16: 138ms

			// Perm and Comb (8000, 4000) Debug Mode
			// 07.03.16: 905ms
			// 07.03.16: 483ms

			_ = BIntMath.permutations(8000, 4000)
			_ = BIntMath.combinations(8000, 4000)
		}
	}

	static func multiplicationBalanced()
	{
		let b1 = BIntMath.randomBInt(bits: 270_000)
		let b2 = BIntMath.randomBInt(bits: 270_000)

		benchmarkAndPrint(title: "Multiply two random BInts with size of 270_000 and 270_000 bits")
		{
			// Multiply two random BInts with size of 270_000 and 270_000 bits
			// 26.04.18: 2427ms

			_ = b1 * b2
		}
	}

	static func multiplicationUnbalanced()
	{
		let b1 = BIntMath.randomBInt(bits: 70_000_000)
		let b2 = BIntMath.randomBInt(bits: 1_000)

		benchmarkAndPrint(title: "Multiply two random BInts with size of 70_000_000 and 1_000 bits")
		{
			// Multiply two random BInts with size of 70_000_000 and 1_000 bits
			// 26.04.18: 2467ms

			_ = b1 * b2
		}
	}
}
