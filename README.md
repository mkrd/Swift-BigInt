## Installation

Simply drag the BInt and BDouble.swift file into your project!



## Usage

#### You can initialize BInt with the following constructors:
* BInt(Int)
* BInt(UInt)
* BInt(String) 

#### BDouble allows these constructors:
* BDouble(Int)
* BDouble(Double)
* BDouble(Int, over: Int)
* BDouble(String, over: String)

#### Examples:
* let i = BInt(12)
* let i = BInt(-9234)
* let d = BDouble(221)
* let d = BDouble(1.192)
* let d = BDouble(3, over: 4)
* let d = BDouble("1" over: "3421342675925672365438867862653658268376582356831563158967")

#### BInt offers 5 class methods:
* BInt.description: Returns String representation of BInt
*   Also works with print: print(BInt)
* BInt.isPositive(): Returns Bool
* BInt.isNegative(): Returns Bool
* BInt.isZero(): Returns Bool
* BInt.negate(): Returns noting, but negates the BInt

### The following Operators work with BInt:

* BInt + BInt: Returns BInt
* BInt + Int: Returns BInt
* Int + BInt: Returns BInt

* BInt += BInt
* BInt += Int
* Int += BInt

* BInt - BInt: Returns BInt
* BInt - Int: Returns BInt
* Int - BInt: Returns BInt

* BInt -= BInt
* BInt -= Int
* Int -= BInt

* BInt * BInt: Returns BInt
* BInt * Int: Returns BInt
* Int * BInt: Returns BInt

* BInt *= BInt
* BInt *= Int
* Int *= BInt

* BInt ^ Int: Returns BInt to the power of Int as BInt

* BInt == BInt
* BInt !== BInt (should be !=)


* BInt < BInt
* BInt > BInt
* BInt <= BInt
* BInt >= BInt

* BInt % BInt: Returns BInt
* BInt % Int: Returns BInt
* Int % BInt: Returns BInt

* BInt %= BInt
 
* BInt / BInt: Returns BInt

* BInt /= BInt


#### Implemented BInt functions:

* fkt(Int): Returns BInt
* gcd(BInt, BInt): Returns BInt
* lcm(BInt, BInt): Returns BInt
* permutations(BInt, BInt): Returns BInt
* combinations(BInt, BInt): Returns BInt

## BDouble descriptions follows, BDouble needs more funtionality
If you really need it, look at the implementation for supported operators.







## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
