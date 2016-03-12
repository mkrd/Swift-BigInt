# BInt and BDouble
This is a lightweight, and easy-to-use, multiple precision arithmetric library for Swift. It supports whole Numbers (BInt) and Fractions (BDouble) with most of the common math operators like addition, subtraction, multiplication, exponentiation, modulus and division. Some optimized math functions like factorial or gcd are also implemented. So more details, continue reading.

Some benchmarks are located in Benchmarks.swift, note that these are more than 10 times faster in release mode.



## Installation
Simply drag the BInt and BDouble.swift file into your project!





## Usage
This subsection explains the usage of BInt and BDouble

### BInt

#### You can initialize BInt with the following constructors:
```swift
BInt(Int)
BInt(UInt)
BInt(String) 
```

#### Examples:
```swift
let i = BInt(12)
let i = BInt(-9234)
let i = BInt("-2343241765837645983267582365876326491813491053680428560284652986203287826526")
```

#### BInt offers 7 struct methods:
```swift
let big = BInt("-143141341")

big.description // Returns "-143141341"
=> print(big) // prints "-143141341"

big.toInt() // returns -143141341 (only works when Int.min <= big <= Int.max)

big.isPositive() // Returns false
big.isNegative() // Returns true
big.isZero() // Returns false

big.negate() // Returns noting, but negates the BInt (mutating func)

big.rawData() // Returns internal structure
```

### The following Operators work with BInt:
```swift
// Operating on Int and BInt result in a typecast to BInt

// Addition
BIntOrInt  +  BIntOrInt // Returns BInt
BIntOrInt  += BIntOrInt

//Subtraction
BIntOrInt  -  BIntOrInt // Returns BInt
BIntOrInt  -= BIntOrInt

// Multiplication
BIntOrInt  *  BIntOrInt // Returns BInt
BIntOrInt  *= BIntOrInt

// Powering
BInt       ^  Int       // Retuns BInt to the power of Int

// Modulo
BIntOrInt  %  BIntOrInt // Returns BInt
BInt       %= BInt

// Division
BInt       /  BInt // Returns BInt
BInt       /= BInt


// Comparing
BInt       == BInt
BInt       != BInt
BInt       <  BInt
BInt       <= BInt
BInt       >  BInt
BInt       >= BInt
```

#### Implemented BInt math functions:
```swift
fact(Int): Returns factorial as BInt

gcd(BInt, BInt): Returns greatest common divisor as BInt

lcm(BInt, BInt) // Returns lowest common multiple as BInt

permutations(BInt, BInt) // Returns BInt

combinations(BInt, BInt) // Returns BInt
```

### BDouble

#### BDouble allows these constructors:
```swift
BDouble(Int)
BDouble(Double)
BDouble(Int, over: Int)
BDouble(String, over: String)
```

#### Examples:
```swift
let d = BDouble(221)
let d = BDouble(1.192)
let d = BDouble(3, over: 4)
let d = BDouble("1" over: "3421342675925672365438867862653658268376582356831563158967")
```

#### BDouble offers these struct methods:
```swift
let bigD = BDouble(-12.32)

bigD.description // Returns "-308/25"
=> print(bigD) // prints "-308/25"


bigD.minimize() // Divides numerator and denominator by their gcd for storage and operation efficiency, usually not neccesary, because of automatic minimization

big.rawData() // Returns internal structure
```

### The following Operators work with BDouble:
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



## About performance
BInt about as fast as mini-gmp, as of now (not counting the normal gmp, because it needs to be installed and is not portable). For example, GMP can calculate multiplications about 1.5 times faster than BInt. However, GMP is significantly harder to use, especially in combination with Swift, while BInt offers an intuitive interface. When given the task of calculating and printing factorials successively, BInt performs significantly better than GMP
I'm considering a new method of storing limbs in base 10^18 instead of 2^64. This adds memory overhead and weaker raw calculation performance, but makes printing several orders of magnitude faster than GMP. For example, my test-implementation with base 10^18 can calculate and print 1! to 20000! in about 5 minutes. GMP can only reach 5680! in the same timeframe.




## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
