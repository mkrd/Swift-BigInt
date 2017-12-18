import Foundation

benchmarkPrint(title: "All tests pased, duration")
{
    SMP_Tests.testBaseConversionRandom()
    SMP_Tests.testBIntRandom()
    SMP_Tests.testBInt()
	SMP_Tests.testSteinGcd()

    MG_Matrix_Tests.testSparseMatrix()
}

Benchmarks.BDoubleConverging()
Benchmarks.exponentiation()
Benchmarks.factorial()
Benchmarks.fibonacci()
//Benchmarks.Matrix1()
//Benchmarks.mersennes()
Benchmarks.BIntToString()
//Benchmarks.StringToBInt()
//Benchmarks.permutationsAndCombinations()











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
//
//
//
//
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
//
//
//benchmarkPrint(title: "hm")
//{
//    makeAndSave()
//}





