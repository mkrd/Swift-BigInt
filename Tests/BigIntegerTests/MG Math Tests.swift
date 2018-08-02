/*
*   ————————————————————————————————————————————————————————————————————————————
*   ||||||||        MG Math Tests        |||||||||||||||||||||||||||||||||||||||
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 05.09.17.
*   Copyright © 2017 Marcel Kröker. All rights reserved.
*/

import Foundation
import Tools
import XCTest


public class MG_Math_Tests: XCTestCase
{
    func test_primesTo()
	{
		for i in 2...200
		{
			let primes = math.primesThrough(i)

			for j in 2...i
			{
				if math.isPrime(j)
				{
					XCTAssert(primes.contains(j), "\(j) is prime but not in \(primes), i = \(i)")
				}
				else
				{
					XCTAssert(!primes.contains(j), "\(j) is not prime but in \(primes), i = \(i)")
				}
			}
		}

//		benchmarkPrint(title: "primes") {
//			let n = math.primesThrough(150_000_000)
//			print("\(Double(n.count) / 1_000_000.0) Million")
//		}
	}
}
