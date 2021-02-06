# Swift-BigInt
Swift-BigInt is a lightweight, and easy-to-use, arbitrary precision arithmetric library for Swift 5. 

It supports whole Numbers (BInt) and Fractions (BDouble) with most of the common math operators. Optimized mathematical functions like factorial or gcd are also implemented and are accessible through BIntMath. For more details, please continue reading.

Some benchmarks are located in Benchmarks.swift, note that these are more than 10 times faster in the release mode, compared to the debug mode of Xcode.

# Survey Time!

[Survey Link](https://forms.gle/9ycR8eUEsCenvMUn7)

We want to hear your opinion about Swift BigInt! If you have a few minutes, please help us with answering a few questions about how you use this project, and tell us your opinion about it. The survey is completely anonymous, and will be used to evaluate which features will be prioritized in the future.




# Installation

## Drag and Drop
One of the main goals of this library is to be lightweight and independent.

Simply drag and drop `Swift-Big-Number-Core.swift` from the `sources` folder into your project!

Yes, it's that easy :)


## Swift Package Manager

You can use the [Swift Package Manager](https://swift.org/package-manager/) and specify the  package dependency in your `Package.swift` file by adding this:
```
.Package(url: "https://github.com/mkrd/Swift-BigInt.git", branch: "master")
```

```
import BigNumber
```


## CocoaPods

Put the following in your Podfile:
```
pod 'BigNumber', '~> 2.0', :git => 'https://github.com/mkrd/Swift-Big-Integer.git'
```


# Compatibility
It is recommended to use Xcode 9+ and Swift 4+. Issues have been reported with older versions, so you might want to use an older version of this library if you can't update.


# Getting Started
Here is a small example, to showcase some functionalities of this library. If you want to learn more, please continue reading the Usage section below.

```swift
let a = BInt(12)
let b = BInt("-10000000000000000000000000000000000000000000000000000000000000000")!

print(b)
>>> -10000000000000000000000000000000000000000000000000000000000000000

print(-a * b)
>>> 120000000000000000000000000000000000000000000000000000000000000000

print(BInt(200).factorial())
>>> 788657867364790503552363213932185062295135977687173263294742533244359449963403342920304284011984623904177212138919638830257642790242637105061926624952829931113462857270763317237396988943922445621451664240254033291864131227428294853277524242407573903240321257405579568660226031904170324062351700858796178922222789623703897374720000000000000000000000000000000000000000000000000
```

# Usage

## BInt

### Initialization
You initialize BInt with `Int`, `UInt`, and `String`. If you use a `String`, the initialized `BInt` will be an optional type, which will be empty if the `String` does not contain an valid number.

```
BInt(Int)
BInt(UInt)
BInt(String)?
BInt(String, radix: Int)?
```

### Examples
```swift
let a = BInt(12)
print(a)
>>> 12


let b = BInt("-234324176583764598326758236587632649181349105368042856028465298620328782652623")
print(b!)
>>> -234324176583764598326758236587632649181349105368042856028465298620328782652623


let invalid = BInt("I'm not a number")
if let c = invalid {
  print(c)
} else {
  print("Not a valid number!")
}
>>> Not a valid number!


let d = BInt("fff", radix: 16)
print(d)
>>> 4095
```

### BInt offers these struct methods
```swift
let big = BInt("-143141341")!

big.description // Returns "-143141341"
=> print(big) // prints "-143141341"

big.toInt() // returns -143141341 (only works when Int.min <= big <= Int.max)

big.isPositive() // Returns false
big.isNegative() // Returns true
big.isZero() // Returns false

big.negate() // Returns noting, but negates the BInt (mutating func)

big.rawData() // Returns internal structure
```

## The following Operators work with BInt
```swift
// Operating on Int and BInt result in a typecast to BInt

// Addition
BIntOrInt  +  BIntOrInt // Returns BInt
BIntOrInt  += BIntOrInt

//Subtraction
BIntOrInt -  BIntOrInt // Returns BInt
BIntOrInt -= BIntOrInt

// Multiplication
BIntOrInt *  BIntOrInt // Returns BInt
BIntOrInt *= BIntOrInt

// Exponentiation
BInt ** Int       // Retuns BInt to the power of Int

// Modulo
BIntOrInt  %  BIntOrInt // Returns BInt
BInt       %= BInt

// Division
BInt /  BInt // Returns BInt
BInt /= BInt


// Comparing
BInt == BInt
BInt != BInt
BInt <  BInt
BInt <= BInt
BInt >  BInt
BInt >= BInt
```

### Implemented BInt math functions
```swift
fact(Int) // Returns factorial as BInt

gcd(BInt, BInt) // Returns greatest common divisor as BInt

lcm(BInt, BInt) // Returns lowest common multiple as BInt

permutations(BInt, BInt) // Returns BInt

combinations(BInt, BInt) // Returns BInt
```

### Compatibility with Bignum

`BInt` has a typealias to `Bignum` that is largely drop-in compatible with the OpenSSL-based [Swift big number library](https://github.com/Bouke/Bignum).  The following properties and operations are available on `BInt`/`Bignum`:

```swift
public var data: Data				/// Representation as big-endian Data
public var dec: String				/// Decimal string representation
public var hex: String				/// Hexadecimal string representation

public init(hex: String)			/// Initialise a new BInt from a hexadecimal string
public init(_ n: UInt64)			/// Initialise from an unsigned, 64 bit integer
public init(data: Data)				/// Initialise from big-endian Data

/// Combined exponentiation/modulo algorithm
///
/// - Parameters:
///   - b: base
///   - p: power
///   - m: modulus
/// - Returns: pow(b, p) % m
public func mod_exp(_ b: BInt, _ p: BInt, _ m: BInt) -> BInt

/// Non-negative modulo operation
///
/// - Parameters:
///   - a: left hand side of the module operation
///   - m: modulus
/// - Returns: r := a % b such that 0 <= r < abs(m)
public func nnmod(_ a: BInt, _ m: BInt) -> BInt
```

## BDouble

### BDouble allows these constructors
```swift
BDouble(Int)
BDouble(Double)
BDouble(String)?
BDouble(Int, over: Int)
BDouble(String, over: String)?
BDouble(String, radix: Int)?
```

### Examples
```swift
let integer = BDouble(221)
let double = BDouble(1.192)
let fraction = BDouble(3, over: 4)
let stringFraction = BDouble("1" over: "3421342675925672365438867862653658268376582356831563158967")!
```

### BDouble offers these struct methods
```swift
let bigD = BDouble(-12.32)

bigD.description // Returns "-308/25"
=> print(bigD) // prints "-308/25"


bigD.minimize() // Divides numerator and denominator by their gcd for storage and operation efficiency, usually not neccesary, because of automatic minimization

bigD.rawData() // Returns internal structure
```

## The following Operators work with BDouble
```swift
// Needs more operators, interoperability with BInt

// Addition
BDouble + BDouble // Returns BDouble

// Subtraction
BDouble - BDouble // Returns BDouble

// Multiplication
BDouble * BDouble // Returns BDouble

// Division
BDouble / BDouble // Returns BDouble

// Comparing
BDouble < BDouble
/*
Important:
a < b <==> b > a
a <= b <==> b >= a
but:
a < b <==> !(a >= b)
a <= b <==> !(a > b)
*/

// More will follow
```



# About performance
BInt about twice as fast as mini-gmp, as of now (not counting the normal gmp, because it needs to be installed and is not portable). For example, BInt can add numbers about 2 times faster than GMP (272ms vs 530ms for fib(100,000)), and multiplication is more than twice as fast. When given the task of calculating and printing factorials successively, BInt performs significantly better than GMP. In addition, GMP is significantly harder to use, while BInt offers an intuitive interface.



# Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
