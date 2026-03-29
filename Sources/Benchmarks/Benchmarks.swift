import Foundation
@testable import BigNumber
@testable import MGTools

struct BenchmarkEntry {
    let name: String
    let setup: () -> (() -> Void)
}

struct BenchmarkResult: Codable {
    let name: String
    let measurements: [Int]
    var avg: Int { measurements.reduce(0, +) / max(measurements.count, 1) }
}

struct BenchmarkResults: Codable {
    let results: [BenchmarkResult]
}

let allBenchmarks: [BenchmarkEntry] = [
    BenchmarkEntry(name: "BDouble converging to two for 3000 steps") { {
        var res: BDouble = 0
        var den: BInt = 1
        for _ in 0..<3000 {
            res = res + BDouble(BInt(1), over: den)
            den *= 2
        }
    }},

    BenchmarkEntry(name: "10^300_000") { {
        _ = BInt(10) ** 300_000
    }},

    BenchmarkEntry(name: "Factorial of 40_000") { {
        _ = BInt(40_000).factorial()
    }},

    BenchmarkEntry(name: "Fib 100000") { {
        _ = BIntMath.fib(100_000)
    }},

    BenchmarkEntry(name: "Matrix ^ 500") {
        let A = Matrix<BDouble>(
            [[2, 5, -2],
             [3, 5,  6],
             [-55, 4, 3]]
        )
        return {
            var R = A
            for _ in 0...500 { R = R * A }
        }
    },

    BenchmarkEntry(name: "Mersennes to 2^512") { {
        for i in 1...512 {
            if math.isPrime(i) && BIntMath.isMersenne(i) { _ = i }
        }
    }},

    BenchmarkEntry(name: "Get 15000! as String") {
        let n = BInt(15_000).factorial()
        return { _ = n.description }
    },

    BenchmarkEntry(name: "Factorial 30_000 as String") {
        let s = BInt(30_000).factorial().description
        return { _ = BInt(s)! }
    },

    BenchmarkEntry(name: "Perm and Comb (8000, 4000)") { {
        _ = BIntMath.permutations(8000, 4000)
        _ = BIntMath.combinations(8000, 4000)
    }},

    BenchmarkEntry(name: "Multiply 270k x 270k bit") {
        let b1 = BIntMath.randomBInt(bits: 270_000)
        let b2 = BIntMath.randomBInt(bits: 270_000)
        return { _ = b1 * b2 }
    },

    BenchmarkEntry(name: "Multiply 70M x 1k bit") {
        let b1 = BIntMath.randomBInt(bits: 70_000_000)
        let b2 = BIntMath.randomBInt(bits: 1_000)
        return { _ = b1 * b2 }
    },

    BenchmarkEntry(name: "Divide 200k by 100k bit") {
        let b1 = BIntMath.randomBInt(bits: 200_000)
        let b2 = BIntMath.randomBInt(bits: 100_000)
        return { _ = b1 / b2 }
    },

    BenchmarkEntry(name: "Divide 10M by 1k bit") {
        let b1 = BIntMath.randomBInt(bits: 10_000_000)
        let b2 = BIntMath.randomBInt(bits: 1_000)
        return { _ = b1 / b2 }
    },

    BenchmarkEntry(name: "GCD of two 130k-bit BInts") {
        let b1 = BIntMath.randomBInt(bits: 130_000)
        let b2 = BIntMath.randomBInt(bits: 130_000)
        return { _ = BIntMath.gcd(b1, b2) }
    },

    BenchmarkEntry(name: "mod_exp 1800-bit") {
        let base = BIntMath.randomBInt(bits: 1800)
        let exp = BIntMath.randomBInt(bits: 1800)
        let modulus = BIntMath.randomBInt(bits: 1800)
        return { _ = BIntMath.mod_exp(base, exp, modulus) }
    },

    BenchmarkEntry(name: "BDouble division 100k-bit") {
        let num = BDouble(BIntMath.randomBInt(bits: 100_000), over: BInt(7))
        let den = BDouble(BIntMath.randomBInt(bits: 100_000), over: BInt(13))
        return { _ = num / den }
    },

    BenchmarkEntry(name: "BDouble decimal expansion 70k digits") {
        let val = BDouble(1, over: 7)
        return { _ = val.decimalExpansion(precisionAfterDecimalPoint: 70_000, rounded: false) }
    },

    BenchmarkEntry(name: "1500! to hex string") {
        let big = BInt(1_500).factorial()
        return { _ = big.asString(radix: 16) }
    },

    BenchmarkEntry(name: "Shift 1M-bit left by 5M, 100 times") {
        let big = BIntMath.randomBInt(bits: 1_000_000)
        return {
            var x = big
            for _ in 0..<100 { x = x << 5_000_000 }
        }
    },
]

func runAllBenchmarks(runs: Int = 1) -> [BenchmarkResult] {
    var results: [BenchmarkResult] = []
    for entry in allBenchmarks {
        var measurements: [Int] = []
        for run in 1...runs {
            let body = entry.setup()
            let ms = benchmark("ms", body)
            measurements.append(ms)
            if runs > 1 {
                print("  \(entry.name) [\(run)/\(runs)]: \(ms)ms")
            } else {
                print("  \(entry.name): \(ms)ms")
            }
        }
        let result = BenchmarkResult(name: entry.name, measurements: measurements)
        if runs > 1 {
            print("  \(entry.name) avg: \(result.avg)ms\n")
        }
        results.append(result)
    }
    return results
}
