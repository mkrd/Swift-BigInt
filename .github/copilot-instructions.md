# Swift-BigInt

Swift 4.2 big number library (`BInt`, `BDouble`) with no external dependencies.

## Build & Test

```sh
swift build                # debug build
swift test                 # run all tests
just test-verify           # release-mode correctness checks
just test-full             # same as swift test
```

## Benchmarks

```sh
just bench                 # run benchmarks, print results
just bench-save            # run benchmarks, save baseline to performance_baseline.json
just bench-compare         # run benchmarks, compare against saved baseline
just bench 3               # run each benchmark 3 times, show per-run + average
just bench-save 3           # save baseline averaged over 3 runs
just bench-compare 3        # compare averages over 3 runs against baseline
```

The `Benchmarks` binary accepts subcommands directly:
- `Benchmarks [runs]` — print results
- `Benchmarks save <file> [runs]` — save results as JSON
- `Benchmarks compare <file> [runs]` — compare current run against JSON baseline

Benchmarks are defined declaratively in `Sources/Benchmarks/Benchmarks.swift` as a `[BenchmarkEntry]` array. Each entry has a name and a `setup` closure that returns the timed `body` closure. Setup work (allocations, precomputation) is not included in the measurement.

To add a benchmark, append a `BenchmarkEntry` to `allBenchmarks`. Then run `just bench-save` to update the baseline.
