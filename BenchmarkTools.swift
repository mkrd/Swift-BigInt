import Foundation
import Cocoa


/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
/********\
/*********\
/**********\
//MARK:    - Benchmark tools
\**********/
\*********/
\********/
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

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

func benchmarkPrint(precision: String = "ms", title: String, _ call: () -> ())
{
	print(title + ": \(benchmark(precision, call))" + precision)
}

func benchmarkAvg(precision: String = "ms",
	title: String = "",
	times: Int = 100,
	_ call: () -> ()) -> (min: Int, avg: Int, max: Int)
{
	let emptyCallsNano = performanceInNs(
	{
		for _ in 0..<times {}
	})

	var min = Int.max
	var max = 0

	var elapsedNanoCombined = 0

	for _ in 0..<times
	{
		let duration = performanceInNs(call)

		if duration < min { min = duration }
		if duration > max { max = duration }


		elapsedNanoCombined += duration
	}

	let elapsedCorrected = elapsedNanoCombined < emptyCallsNano ? 0 : elapsedNanoCombined - emptyCallsNano

	return (adjustPrecision(min, toPrecision: precision),
		    adjustPrecision(elapsedCorrected / times, toPrecision: precision),
			adjustPrecision(max, toPrecision: precision)
	)
}
