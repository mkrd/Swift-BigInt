import Foundation

func printUsage() {
    print("Usage: Benchmarks [save <file> | compare <file>] [runs]")
    print("  (no args)       Run benchmarks and print results")
    print("  save <file>     Run benchmarks and save results as JSON")
    print("  compare <file>  Run benchmarks and compare against saved baseline")
    print("  [runs]          Number of times to run each benchmark (default: 1)")
}

func loadBaseline(from path: String) -> [String: Int] {
    let url = URL(fileURLWithPath: path)
    let data = try! Data(contentsOf: url)
    let baseline = try! JSONDecoder().decode(BenchmarkResults.self, from: data)
    var dict: [String: Int] = [:]
    for r in baseline.results { dict[r.name] = r.avg }
    return dict
}

func saveResults(_ results: [BenchmarkResult], to path: String) {
    let wrapped = BenchmarkResults(results: results)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try! encoder.encode(wrapped)
    let url = URL(fileURLWithPath: path)
    try! data.write(to: url)
    print("\nSaved to \(path)")
}

func printComparison(_ results: [BenchmarkResult], baselinePath: String) {
    let baseline = loadBaseline(from: baselinePath)
    let nameWidth = results.map { $0.name.count }.max()! + 2

    print("")
    let header = "Benchmark".padding(toLength: nameWidth, withPad: " ", startingAt: 0)
        + "Baseline".padding(toLength: 12, withPad: " ", startingAt: 0)
        + "Current".padding(toLength: 12, withPad: " ", startingAt: 0)
        + "Speedup"
    print(header)
    print(String(repeating: "─", count: header.count))

    for r in results {
        let current = r.avg
        let name = r.name.padding(toLength: nameWidth, withPad: " ", startingAt: 0)
        if let base = baseline[r.name] {
            let speedup = current > 0 ? String(format: "%.2fx", Double(base) / Double(current)) : "inf"
            print(name
                + "\(base)ms".padding(toLength: 12, withPad: " ", startingAt: 0)
                + "\(current)ms".padding(toLength: 12, withPad: " ", startingAt: 0)
                + speedup)
        } else {
            print(name
                + "—".padding(toLength: 12, withPad: " ", startingAt: 0)
                + "\(current)ms".padding(toLength: 12, withPad: " ", startingAt: 0)
                + "(new)")
        }
    }
}

// Main
let args = Array(CommandLine.arguments.dropFirst())

func parseRuns(from args: [String], afterIndex idx: Int) -> Int {
    if args.count > idx, let n = Int(args[idx]), n > 0 { return n }
    return 1
}

switch args.first {
case nil:
    print("Running benchmarks...\n")
    _ = runAllBenchmarks()

case let s where Int(s ?? "") != nil:
    let runs = Int(s!)!
    print("Running benchmarks (\(runs) runs each)...\n")
    _ = runAllBenchmarks(runs: runs)

case "save":
    guard args.count >= 2 else { printUsage(); exit(1) }
    let runs = parseRuns(from: args, afterIndex: 2)
    print("Running benchmarks (\(runs) runs each)...\n")
    let results = runAllBenchmarks(runs: runs)
    saveResults(results, to: args[1])

case "compare":
    guard args.count >= 2 else { printUsage(); exit(1) }
    let runs = parseRuns(from: args, afterIndex: 2)
    print("Running benchmarks (\(runs) runs each)...\n")
    let results = runAllBenchmarks(runs: runs)
    printComparison(results, baselinePath: args[1])

default:
    printUsage()
    exit(1)
}
