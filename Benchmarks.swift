benchmarkPrint(title: "BInt tests")
{
	testBInt()
}

let fff2 = fact(1000)
benchmarkPrint(title: "Get 1000! as String")
{
	// Get 300! (615 decimal digits) as String Debug Mode
	// 30.01.16: 2635ms
	// 01.02.16: 3723ms
	// 04.02.16: 2492m
	// 06.02.16: 2326ms
	// 07.02.16: 53ms

	// Get 1000! (2568 decimal digits) as String Debug Mode
	// 07.02.16: 2416ms

	let str = fff2.description
}

benchmarkPrint(title: "Mersenne to exp 196 only prime")
	{
		// Mersenne to exp 150 only prime Debug Mode
		// 27.01.16: 2384ms
		// 30.01.16: 1874ms
		// 01.02.16: 1750ms
		// 04.02.16: 1070ms
		// 06.02.16: 943ms

		// Mersenne to exp 196 only prime Debug Mode
		// 06.02.16: 2601ms

		let a = getMersennes(196)
		print(a)
}

benchmarkPrint(title: "Mersenne to exp 128")
	{
		// Mersenne to exp 100 Debug Mode
		// 27.01.16: 2559ms
		// 30.01.16: 2092ms
		// 04.02.16: 1330ms
		// 06.02.16: 1143ms

		// Mersenne to exp 128 Debug Mode
		// 06.02.16: 2853ms

		var isM = false
		for i in 1...128
		{
			isM = isMersenne(i)
		}
}

var fkt2000 = BInt(0)
benchmarkPrint(title: "Fkt of 4000")
{
	// Fkt 1000  Debug Mode
	// 27.01.16: 2548ms
	// 30.01.16: 1707ms
	// 01.02.16: 398ms

	// Fkt 2000  Debug Mode
	// 01.02.16: 2452ms
	// 04.02.16: 2708ms
	// 06.02.16: 328ms

	// Fkt 4000  Debug Mode
	// 06.02.16: 2669ms

	fkt2000 = fact(4000)
}

benchmarkPrint(title: "10^14000")
{
	// 10^14000 Debug Mode
	// 06.02.16: 2668ms

	let a = BInt(10) ^ 14000
}

benchmarkPrint(title: "Fib 100.000")
	{
		// Fib 35.000 Debug Mode
		// 27.01.16: 2488ms
		// 30.01.16: 1458ms
		// 01.02.16: 357ms

		// Fib 100.000 Debug Mode
		// 01.02.16: 2733ms
		// 04.02.16: 2949ms

		let a = fib(100_000)
}



benchmarkPrint(title: "Perm and Comb")
	{
		// Perm and Comb (2000, 1000) Debug Mode
		// 04.02.16: 2561ms
		// 06.02.16: 2098ms
		// 07.02.16: 1083ms

		let a = permutations(2000, 1000)
		let b = combinations(2000, 1000)
}


benchmarkPrint(title: "BDouble converging to 2")
{
	// BDouble converging to 2 Debug Mode
	// 06.02.16: 3351ms

	var res = BDouble(0)
	var den = BInt(1)

	for i in 0..<1000
	{
		res = res + BDouble(BInt(1), over: den)
		den = den * BInt(2)
	}
}
