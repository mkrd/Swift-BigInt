/*
*   ————————————————————————————————————————————————————————————————————————————
*   ||||||||        MG Math Tests        |||||||||||||||||||||||||||||||||||||||
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 05.09.17.
*   Copyright © 2017 Marcel Kröker. All rights reserved.
*/

import XCTest
@testable import MGTools

class MG_Math_Tests: XCTestCase {
    func test_primesTo() {
        measure {
            for i in 2...200
            {
                let primes = math.primesThrough(i)

                for j in 2...i
                {
                    if math.isPrime(j)
                    {
                        precondition(primes.contains(j), "\(j) is prime but not in \(primes), i = \(i)")
                    }
                    else
                    {
                        precondition(!primes.contains(j), "\(j) is not prime but in \(primes), i = \(i)")
                    }
                }
            }
        }
    }
    
}
