/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Benchmark Tools.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 03.04.2015.
*   Copyright © 2015 Marcel Kröker. All rights reserved.
*/

import Foundation
#if os(Linux)
	import Glibc

	private func mach_absolute_time() -> UInt64 {
		var tv = timeval();
		guard gettimeofday(&tv, nil) != -1 else { return 0 }

		let t = UInt64(tv.tv_usec) + UInt64(tv.tv_sec) * 1000000
		return t;
	}

	private struct mach_timebase_info_data_t {
		var numer: Int = 1000
		var denom: Int = 1
	}

	private func mach_timebase_info(_: inout mach_timebase_info_data_t) {}
#endif

/// Returns the time in nanoseconds it took to execute the call.
private func durationNS(_ call: () -> ()) -> Int
{
	var start = UInt64()
	var end = UInt64()

	start = mach_absolute_time()
	call()
	end = mach_absolute_time()

	var timeBaseInfo = mach_timebase_info_data_t()
	mach_timebase_info(&timeBaseInfo)

	return Int(end - start) * Int(timeBaseInfo.numer) / Int(timeBaseInfo.denom)
}

private func adjustPrecision(_ ns: Int, toPrecision: String) -> Int
{
	switch toPrecision
	{
		case "ns": // nanoseconds
			return ns
		case "us": // microseconds
			return ns / 1_000
		case "ms": // milliseconds
			return ns / 1_000_000
		default: // seconds
			return ns / 1_000_000_000
	}
}

/**
Measure execution time of trailing closure.

- Parameter precision: Precision of measurement. Possible
values:
- "ns": nanoseconds
- "us": microseconds
- "ms" or omitted parameter: milliseconds
- "s" or invalid input: seconds
*/
public func benchmark(_ precision: String = "ms", _ call: () -> ()) -> Int
{
	// empty call duration to subtract
	let emptyCallElapsedNS = durationNS({})
	let elapsedNS = durationNS(call)

	let elapsedCorrected = elapsedNS >= emptyCallElapsedNS
		? elapsedNS - emptyCallElapsedNS
		: 0

	return adjustPrecision(elapsedCorrected, toPrecision: precision)
}

/**
Measure execution time of trailing closure, and print result
with description into the console.

- Parameter precision: Precision of measurement. Possible
values:
- "ns": nanoseconds
- "us": microseconds
- "ms" or omitted parameter: milliseconds
- "s" or invalid input: seconds

- Parameter title: Description of benchmark.
*/
public func benchmarkAndPrint(_ precision: String = "ms", title: String, _ call: () -> ())
{
	print("=> \(title): \(benchmark(precision, call))\(precision)")
}


/**
Measure the average execution time of trailing closure.

- Parameter precision: Precision of measurement. Possible
values:
- "ns": nanoseconds
- "us": microseconds
- "ms" or omitted parameter: milliseconds
- "s" or invalid input: seconds

- Parameter title: Description of benchmark.

- Parameter times: Amount of executions.
Default when parameter is omitted: 100.

- Returns: Minimum, Average and Maximum execution time of
benchmarks as 3-tuple.
*/
public func benchmarkAvg(
	_ precision: String = "ms",
	times: Int = 10,
	_ call: () -> ())
	-> (min: Int, avg: Int, max: Int)
{
	let emptyCallsNS = durationNS({
			for _ in 0..<times {}
	})

	var min = Int.max
	var max = 0

	var elapsedNSCombined = 0

	for _ in 0..<times
	{
		let duration = durationNS(call)

		if duration < min { min = duration }
		if duration > max { max = duration }

		elapsedNSCombined += duration
	}

	let elapsedCorrected = elapsedNSCombined >= emptyCallsNS
		? elapsedNSCombined - emptyCallsNS
		: 0

	return (
		adjustPrecision(min, toPrecision: precision),
		adjustPrecision(elapsedCorrected / times, toPrecision: precision),
		adjustPrecision(max, toPrecision: precision)
	)
}

public func benchmarkAvgPrint(
	_ precision: String = "ms",
	title: String,
	_ times: Int = 10,
	_ call: () -> ())
{
	let (min, avg, max) = benchmarkAvg(precision, times: times, call)

	let avgDur = "\(avg)" + precision + " average, "
	let minDur = "\(min)" + precision + " min, "
	let maxDur = "\(max)" + precision + " max"

	print("=> \(title): \(times) times, " + avgDur + minDur + maxDur)
}
