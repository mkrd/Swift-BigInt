import Foundation


func iterateByLowestSumOfComponents(_ imax: Int, _ jmax: Int) -> [(Int, Int)]
{
	var i, j: Int
	var grid = [(Int, Int)]()

	for sum in 0...(imax + jmax)
	{
		if sum < imax { (i, j) = (sum, 0) }
		else { (i, j) = (imax, sum - imax) }

		while j <= jmax && i >= 0
		{
			grid.append((i, j))
			(i, j) = (i - 1, j + 1)
		}
	}
	return grid
}


print("Run Started.")




func generateDoubleString(preDecimalCount: Int, postDecimalCount: Int) -> String
{
	var numStr = ""

	if preDecimalCount == 0 && postDecimalCount == 0
	{
		return math.random(0...1) == 1 ? "0" : "0.0"
	}

	if preDecimalCount == 0
	{
		numStr = "0."
	}

	if postDecimalCount == 0
	{
		numStr = math.random(0...1) == 1 ? "" : ".0"
	}


	for i in 0..<preDecimalCount
	{
		if i == (preDecimalCount - 1) && preDecimalCount > 1
		{
			numStr = math.random(1...9).description + numStr
		}
		else
		{
			numStr = math.random(0...9).description + numStr
		}
	}

	if postDecimalCount != 0 && preDecimalCount != 0
	{
		numStr += "."
	}

	for _ in 0..<postDecimalCount
	{
		numStr = numStr + math.random(0...9).description
	}

	return math.random(0...1) == 1 ? numStr : "-" + numStr
}




for _ in 0..<200000
{
	let preDecimalCount = math.random(0...4)
	let postDecimalCount = math.random(0...4)
	let doubleString = generateDoubleString(
		preDecimalCount: preDecimalCount,
		postDecimalCount: postDecimalCount
	)

	let toBDoubleAndBack = BDouble(doubleString)!.decimalExpansion(precisionAfterComma: postDecimalCount)

	if toBDoubleAndBack != doubleString
	{
		if doubleString == "0" && toBDoubleAndBack == "0.0" { continue }
		if doubleString == "-0" && toBDoubleAndBack == "0.0" { continue }
		if doubleString == "-0.0" && toBDoubleAndBack == "0.0" { continue }
		if doubleString == "-0.00" && toBDoubleAndBack == "0.00" { continue }
		if doubleString == "-0.000" && toBDoubleAndBack == "0.000" { continue }
		if doubleString.count > 2 && doubleString[..<doubleString.index(doubleString.endIndex, offsetBy: -2)] == toBDoubleAndBack { continue }

		print("\nError: PreDecCount: \(preDecimalCount) PostDecCount: \(postDecimalCount)")
		print("Previ: \(doubleString)")
		print("After: \(toBDoubleAndBack)")
	}
}




benchmarkPrint(title: "Radix test")
{
	let x = BInt("abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef00", radix: 16)!
	print(x.description)
	print(x.asString(radix: 62))


	let y = BInt("-abcdef00", radix: 16)!
	print(y)
	print(y.asString(radix: 16))
}




//benchmarkPrint(title: "All tests passed, duration")
//{
//    SMP_Tests.testBaseConversionRandom()
//    SMP_Tests.testBIntRandom()
//    SMP_Tests.testBInt()
//	SMP_Tests.testSteinGcd()
//
//    MG_Matrix_Tests.testSparseMatrix()
//}

//Benchmarks.BDoubleConverging()
//Benchmarks.exponentiation()
//Benchmarks.factorial()
//Benchmarks.fibonacci()
//Benchmarks.Matrix1()
//Benchmarks.mersennes()
//Benchmarks.BIntToString()
//Benchmarks.StringToBInt()
////Benchmarks.permutationsAndCombinations()
//Benchmarks.multiplicationBalanced()
//Benchmarks.multiplicationUnbalanced()











//public struct PixelData {
//    var a:UInt8 = 255
//    var r:UInt8
//    var g:UInt8
//    var b:UInt8
//}
//
//private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
//
//public func imageFromARGB32Bitmap(pixels:[PixelData], width: Int, height: Int) -> CGImage {
//    let bitsPerComponent: Int = 8
//    let bitsPerPixel: Int = 32
//
//    assert(pixels.count == Int(width * height))
//
//    var data = pixels // Copy to mutable []
//    let providerRef = CGDataProvider(
//        data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
//    )
//
//    let cgim = CGImage(
//        width: width,
//        height: height,
//        bitsPerComponent: bitsPerComponent,
//        bitsPerPixel: bitsPerPixel,
//        bytesPerRow: width * MemoryLayout<PixelData>.size,
//        space: rgbColorSpace,
//        bitmapInfo: bitmapInfo,
//        provider: providerRef!,
//        decode: nil,
//        shouldInterpolate: true,
//        intent: CGColorRenderingIntent.defaultIntent
//    )
//    return cgim!
//}
//
//
//@discardableResult
//func writeCGImage(_ image: CGImage, to destinationURL: URL) -> Bool {
//    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else {
//        print("ERR")
//        return false
//
//    }
//    CGImageDestinationAddImage(destination, image, nil)
//    return CGImageDestinationFinalize(destination)
//}
//
//func makeAndSave()
//{
//    let dimension = 4000
//
//
//    var pixels = [PixelData]()
//
//    for i in 1...(dimension * dimension)
//    {
//        if math.isPrime(i)
//        {
//            pixels.append(PixelData(a: 255, r: 0, g: 0, b: 0))
//        }
//        else
//        {
//            pixels.append(PixelData(a: 0, r: 255, g: 255, b: 255))
//        }
//    }
//
//
//    let img = imageFromARGB32Bitmap(pixels: pixels, width: dimension, height: dimension)
//
//    let writeURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent("name.png")
//
//    writeCGImage(img, to: writeURL)
//}
//
//benchmarkPrint(title: "")
//{
//    makeAndSave()
//}

