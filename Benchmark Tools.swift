import Foundation
import Cocoa

private func performanceInNs(call: () -> ()) -> Int
{
	var start = UInt64()
	var end = UInt64()

	start = mach_absolute_time()
	call()
	end = mach_absolute_time()

	let elapsed = end - start

	var timeBaseInfo = mach_timebase_info_data_t()
	mach_timebase_info(&timeBaseInfo)

	let elapsedNano = Int(elapsed) * Int(timeBaseInfo.numer) / Int(timeBaseInfo.denom)

	return elapsedNano
}

private func adjustPrecision(ns: Int, toPrecision: String) -> Int
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

func benchmark(precision: String = "ms", _ call: () -> ()) -> Int
{
	// empty call duration to subtract
	let emptyCallNano = performanceInNs({})
	let elapsedNano = performanceInNs(call)

	let elapsedCorrected = elapsedNano < emptyCallNano ? 0 : elapsedNano - emptyCallNano

	return adjustPrecision(elapsedCorrected, toPrecision: precision)
}

func benchmark(precision: String = "ms", title: String, _ call: () -> ()) -> String
{
	return title + ": \(benchmark(precision, call))" + precision
}

func benchmarkPrint(precision: String = "ms", title: String, _ call: () -> ())
{
	print(benchmark(precision, title: title, call))
}

func benchmarkAvg(precision: String = "ms",
	title: String = "",
	times: Int = 100,
	_ call: () -> ()) -> Int
{
	let emptyCallsNano = performanceInNs({
		for _ in 0..<times {}
	})

	var elapsedNanoCombined = 0

	for _ in 0..<times {
		elapsedNanoCombined += performanceInNs(call)
	}

	let elapsedCorrected = elapsedNanoCombined < emptyCallsNano ? 0 : elapsedNanoCombined - emptyCallsNano

	return adjustPrecision(elapsedCorrected, toPrecision: precision)
}

func benchmarkMinPrint(precision: String = "ms",
	title: String = "",
	times: Int = 10,
	_ call: () -> ())
{
	var elapsedMin = benchmark(precision, call)

	for _ in 1..<times {
		let newElapsed = benchmark(precision, call)
		if newElapsed > elapsedMin { elapsedMin = newElapsed }
	}

	print(title + ": \(elapsedMin)" + precision)
}
