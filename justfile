bench runs="1":
	swift build -c release --product Benchmarks -Xswiftc -enable-testing
	.build/release/Benchmarks {{runs}}

bench-save runs="1":
	swift build -c release --product Benchmarks -Xswiftc -enable-testing
	.build/release/Benchmarks save assets/benchmark_baseline.json {{runs}}

bench-compare runs="1":
	swift build -c release --product Benchmarks -Xswiftc -enable-testing
	.build/release/Benchmarks compare assets/benchmark_baseline.json {{runs}}

test-verify:
	swift build -c release --product Verify -Xswiftc -enable-testing
	.build/release/Verify

test-full:
	swift test
