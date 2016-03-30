/*
	————————————————————————————————————————————————————————————
	BInt and BDouble
	————————————————————————————————————————————————————————————
	Created by Marcel Kröker on 03.04.15.
	Copyright (c) 2015 Blubyte. All rights reserved.

	———— v1.0 ——————————————————————————————————————————————————
	- Initial Release

	———— v1.1 ——————————————————————————————————————————————————
	- Improved String conversion, now about 45x faster, uses 
	base 10^9 instead of base 10
	- bytes renamed to limbs
	- Uses typealias for limbs and digits

	———— v1.2 ——————————————————————————————————————————————————
	- Improved String conversion, now about 10x faster, switched
	from base 10^9 to 10^18 (biggest possible decimal base)
	- Implemented karatsuba multiplication algorithm, about 5x 
	faster than previous algorithm
	- Addition is 1.3x faster
	- Addtiton and subtraction omit trailing zeros, algorithms
	need less operations now
	- Implemented exponentiation by squaring
	- New storage (BStorage) for often used results
	- Uses uint_fast64_t instead of UInt64 for Limbs and Digits

	———— v1.3 ——————————————————————————————————————————————————
	- Huge Perfomance increase by skipping padding zeros and new
	multiplication algotithms
	- Printing is now about 10x faster, now on par with GMP
	- Some operations now use multiple cores

	———— v1.4 ——————————————————————————————————————————————————
	- Reduced copying by using more pointers
	- Multiplication is about 50% faster
	- String to BInt conversion is 2x faster
	- BInt to String also performs 50% better



	———— Evolution —————————————————————————————————————————————
	Planned features of BInt v2.0:
	- Switch between base for calculation
		- Base 2^64 for fast calculations
		- Base 10^18 for extremely fast printing
	- Implement efficient modulo arithmetric
	- Implement Karatsuba on a higher level for even faster 
	multiplications
	- Implement some basic cryptography functions
	- General code cleanup, better documentation and more 
	extensive tests



	————————————————————————————————————————————————————————————
	Basic Project syntax conventions
	————————————————————————————————————————————————————————————

	———— Naming conventions ————————————————————————————————————
	Parameters, variables, constants, functions and methods:
	lowerCamelCase

	Classes and structs: UpperCamelCase

	———— Formatting ————————————————————————————————————————————
	Indentation: Tabs

	Allman style:
	func foo(...)
	{
		...
	}

	Single line if-statement:
	if ... { ... }

	Maximum comment line length: 64 spaces
	Recommended maximum code line length: 96 spaces

	———— Documentation comments ————————————————————————————————
	/**
		Description 

		- Parameter x: Description
		...

		- Returns: Description
	*/

	———— Marks —————————————————————————————————————————————————
	Marks for rough code structuring:
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
	//MARK:    - Description
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

*/

import Foundation

typealias Limbs  = [UInt64]
typealias Limb   =  UInt64
typealias Digits = [UInt64]
typealias Digit  =  UInt64


//MARK: - FILE DEPENDENCIES:
// - Exceptions and Errors.swift

//MARK: - BInt
public struct BInt:
	IntegerLiteralConvertible,
	FloatLiteralConvertible,
	CustomStringConvertible,
	Comparable,
	Equatable,
	Hashable
{
	/*
	n := element of natural numbers
	no := element of natural numbers including zero
	z := whole numbers

	Data storage: UInt64 array
	[] := undefined (error)
	[0] := 0, defined as positive
	[n] := n

	[k, l, ..., m] :=
	(k * 2^(0*64))
	+ (l * 2^(1*64))
	+ ...
	+ (m * 2^(i*64)),
	where i equals index of m
	=> base 2^64 notation

	*/

	// private data storage. sign == true implies that Number is smaller than Zero
	private var sign = Bool()

	private var limbs = Limbs()

	//MARK: Initializers

	/// init manually without sign (positive by default)
	init(limbs: Limbs)
	{
		if limbs == []
		{
			forceException("BInt can't be initialized with limbs == []")
		}

		self.sign = false
		self.limbs = limbs
	}

	init(sign: Bool, limbs: Limbs)
	{
		self.init(limbs: limbs)
		self.sign = sign
	}

	init(_ z: Int)
	{
		if z == Int.min
		{
			self.init(
				sign: true,
				limbs: [Limb(Int.max) + 1]
			)
			return
		}

		self.init(
			sign: z < 0,
			limbs: [Limb(abs(z))]
		)
	}

	init(_ n: UInt)
	{
		self.init(limbs: [Limb(n)])
	}

	init(_ s: String)
	{
		self = stringToBInt(s)
	}

	public init(floatLiteral value: Double)
	{
		self.init(Int(value))
	}

	public init(integerLiteral value: Int)
	{
		self.init(value)
	}

	// Struct functions

	public func toInt() -> Int
	{
		if self.limbs.count == 1
		{
			if self.limbs[0] <= Limb(Int.max)
			{
				return self.sign ?
					-Int(self.limbs[0]) :
					Int(self.limbs[0])
			}

			if self.limbs[0] == Limb(Int.max) + 1 && self.sign // Int.min
			{
				return Int.min
			}
		}

		forceException("Error: BInt too big for conversion to Int")
		return -1 // never reached
	}

	public var description: String
		{
			return (self.sign ? "-" : "") + limbsToString(self.limbs)
	}

	public func str(radix: Int) -> String
	{
		if !(2...36 ~= radix)
		{
			forceException("Radix must be a power of 2, and <= 32")
		}

		var str = ""

		for i in (self.limbs.count - 1).stride(through: 0, by: -1)
		{
			var new = String(self.limbs[i], radix: radix)

			let z = Int(ceil(log(Double(UInt64.max)) / log(Double(radix))))

			if i != self.limbs.count - 1
			{
				new = String(count: z - new.characters.count, repeatedValue: Character("0")) + new
			}

			str += new
		}
		return str
	}

	public func rawData() -> (sign: Bool, limbs: [UInt64])
	{
		return (self.sign, self.limbs)
	}

	public var hashValue: Int
		{
			return "\(self.sign)\(self.limbs)".hashValue
	}

	public func isPositive() -> Bool { return !self.sign        }
	public func isNegative() -> Bool { return  self.sign        }
	public func isZero()     -> Bool { return self.limbs == [0] }

	mutating func negate()
	{
		if self.limbs != [0]
		{
			self.sign = !self.sign
		}
	}
}

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
//MARK:    - Helpful extensions and functions for easier code
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

extension String
{
	subscript(i: Int) -> String
	{
		return String(self[self.startIndex.advancedBy(i)])
	}

	subscript(r: Range<Int>) -> String
	{
		let length = r.endIndex - r.startIndex
		if length == 0 { return "" }

		let start = startIndex.advancedBy(r.startIndex)
		let end   = start.advancedBy(length)

		return self[start..<end]
	}

	subscript(char: Character) -> Int?
	{
		if let idx = self.characters.indexOf(char)
		{
			return self.startIndex.distanceTo(idx)
		}
		return nil
	}
}

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
//MARK:    - Conversion helper functions
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

let DigitBase:     Digit = 1_000_000_000_000_000_000
let DigitHalfBase: Digit =             1_000_000_000
let DigitZeros           =                        18

private func limbsToString(limbs: Limbs) -> String
{
	return digitsToString(limbsToDigits(limbs))
}

private func limbsToDigits(limbs: Limbs) -> Digits
{
	var res: Digits = [0]
	res.reserveCapacity(limbs.count)

	for i in 0..<limbs.count
	{
		let digit = (limbs[i] < DigitBase)
			? [limbs[i]]
			: [limbs[i] % DigitBase, limbs[i] / DigitBase]

		mulDigits(addInto: &res, digit, BStorage.x_2_64_Digits(i))
	}

	return res
}

private func digitsToString(digits: Digits) -> String
{
	var res = String(digits.last!)

	if digits.count == 1 { return res }

	for i in (digits.count - 2).stride(through: 0, by: -1)
	{
		let str = String(digits[i])

		let paddingZeros = String(
			count: DigitZeros - str.characters.count,
			repeatedValue: Character("0")
		)

		res += (paddingZeros + str)
	}

	return res
}

private func stringToBInt(str: String) -> BInt
{
	var str = str
	var resSign = false
	var resLimbs: Limbs = [0]
	resLimbs.reserveCapacity(Int(Double(str.characters.count) / 19.2))
	var base: Limbs = [1]

	if str[0] == "-"
	{
		str = str[1..<str.characters.count]
		resSign = str != "0"
	}

	for ele in str.characters.reverse()
	{
		guard let b = Limb(String(ele)) else
		{
			forceException("Error: String must only consist of Digits (0-9)")
			return BInt(limbs: [])
		}

		mulLimbs(addInto: &resLimbs, base, [b])

		base = base *° [10]
	}

	return BInt(
		sign: resSign,
		limbs: resLimbs
	)
}

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
//MARK:    - Digit operations
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

private func addDigits(inout lhs: Digits, _ rhs: Digits, rhsPaddingZeros pz: Int)
{
	let lhc = lhs.count
	if pz - lhc == 0 { lhs += rhs; return }
	if pz > lhc { lhs += (BStorage.zeros(pz - lhc) + rhs); return }
	let rhc = rhs.count + pz

	var (newDigit, ovfl) = (Digit(0), false)

	var i = pz
	let min = lhc < rhc ? lhc : rhc

	while i < min
	{
		if ovfl
		{
			newDigit = lhs[i] &+ rhs[i &- pz] &+ 1
		}
		else
		{
			newDigit = lhs[i] &+ rhs[i &- pz]
		}

		ovfl = newDigit >= DigitBase
		if ovfl { newDigit = newDigit &- DigitBase }

		lhs[i] = newDigit
		i += 1
	}

	while ovfl
	{
		if i < lhc
		{
			newDigit = lhs[i] &+ ((i < rhc) ? rhs[i &- pz] : 0) &+ 1
			ovfl = newDigit >= DigitBase
			if ovfl { newDigit = newDigit &- DigitBase }

			lhs[i] = newDigit
		}
		else
		{
			newDigit = ((i < rhc) ? rhs[i &- pz] : 0) &+ 1
			ovfl = newDigit >= DigitBase
			if ovfl { newDigit = newDigit &- DigitBase }

			lhs.append(newDigit)
		}

		i += 1
	}

	if lhs.count < rhc { lhs += rhs[(i &- pz)..<(rhc &- pz)] }
}

private func mulDigits(lhs: Digits, _ rhs: Digits) -> Digits
{
	var res: Digits = [0]
	var singleMul: Digits = [0, 0]
	res.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			mulDigit(&singleMul, lhs[l], rhs[r])

			addDigits(&res, singleMul, rhsPaddingZeros: l + r)
		}
	}

	return res
}

private func mulDigits(inout addInto res: Digits, _ lhs: Digits, _ rhs: Digits)
{
	var singleMul: Digits = [0, 0]

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			mulDigit(&singleMul, lhs[l], rhs[r])
			addDigits(&res, singleMul, rhsPaddingZeros: l + r)
		}
	}
}


private func mulDigit(inout res: Digits, _ lhs: Digit, _ rhs: Digit)// -> Digits
{
	let (mulLo, overflow) = Digit.multiplyWithOverflow(lhs, rhs)

	if !overflow
	{
		if mulLo < DigitBase
		{
			res[0] = mulLo
			if res.count == 2 { res.removeLast() }
		}
		else
		{
			res[0] = mulLo % DigitBase
			res.count == 2 ? res[1] = mulLo / DigitBase : res.append(mulLo / DigitBase)
		}

		return
	}
	// From here, lhs * rhs >= 2^64 => res.count == 2

	let aLo = lhs % DigitHalfBase
	let aHi = lhs / DigitHalfBase
	let bLo = rhs % DigitHalfBase
	let bHi = rhs / DigitHalfBase

	let K = (aHi &* bLo) &+ (bHi &* aLo)

	let rLo = (aLo &* bLo) &+ ((K % DigitHalfBase) &* DigitHalfBase)
	let rHi = (aHi &* bHi) &+ (K / DigitHalfBase)

	if rLo < DigitBase
	{
		res[0] = rLo
		res.count == 2 ? res[1] = rHi : res.append(rHi)

		return
	}

	res[0] = rLo &- DigitBase
	res.count == 2 ? res[1] = rHi &+ 1 : res.append(rHi &+ 1)
}



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
//MARK:    - Limb helper functions
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

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Shifting Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator <<=° {}
private func <<=°(inout lhs: Limbs, rhs: Int)
{
	if rhs == 0 { return }

	let limbShifts =  rhs >> 6
	let singleShifts = rhs & 0x3f

	if singleShifts != 0
	{
		var oldCarry = Limb(0)
		var newCarry = Limb(0)

		for i in 0..<lhs.count
		{
			newCarry = lhs[i] >> UInt64(64 - singleShifts)

			lhs[i] <<= UInt64(singleShifts)
			lhs[i] += oldCarry // carry from last step
			oldCarry = newCarry
		}

		if oldCarry != 0 { lhs.append(oldCarry) }
	}

	if limbShifts != 0 { lhs = BStorage.zeros(limbShifts) + lhs }
}

infix operator >>=° {}
private func >>=°(inout lhs: Limbs, rhs: Int)
{
	if rhs == 0 { return }

	let limbShifts =  rhs >> 6
	let singleShifts = rhs & 0x3f

	if limbShifts >= lhs.count
	{
		lhs = [0]
		return
	}

	lhs = Array(lhs[limbShifts..<lhs.count])

	if singleShifts != 0
	{
		var oldCarry = Limb(0)
		var newCarry = Limb(0)

		for i in (lhs.count - 1).stride(through: 0, by: -1)
		{
			newCarry = lhs[i] << UInt64(64 - singleShifts)

			lhs[i] >>= UInt64(singleShifts)
			lhs[i] += oldCarry
			oldCarry = newCarry
		}
	}

	//if lhs.last! == 0 && lhs.count != 1 {print("lhs: \(lhs)\n shift: \(rhs)"); lhs.removeLast() }
}

infix operator <<° {}
private func <<°(lhs: Limbs, rhs: Int) -> Limbs
{
	var lhs = lhs
	lhs <<=° rhs
	return lhs
}

infix operator >>° {}
private func >>°(lhs: Limbs, rhs: Int) -> Limbs
{
	var lhs = lhs
	lhs >>=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for shifting BInts
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func <<(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		limbs: lhs.limbs <<° rhs
	)
}

public func >>(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		limbs: lhs.limbs >>° rhs
	)
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Adding Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func abs(lhs: BInt) -> BInt
{
	return BInt(
		sign: false,
		limbs: lhs.limbs
	)
}

infix operator +=°  {}
/// Add limbs and wirte result in left Limbs
private func +=°(inout lhs: Limbs, rhs: Limbs)
{
	addLimbs(&lhs, rhs, rhsPaddingZeroLimbs: 0)
}

private func addLimbs(inout lhs: Digits, _ rhs: Digits, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz == lhc { lhs += rhs; return }
	if pz > lhc { lhs += (BStorage.zeros(pz &- lhc) + rhs); return }
	let rhc = rhs.count &+ pz

	var (newLimb, ovfl) = (Limb(0), false)

	let min = lhc < rhc ? lhc : rhc

	var i = pz
	while i < min
	{
		if ovfl
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
			newLimb = newLimb &+ 1

			ovfl = ovfl || newLimb == 0
		}
		else
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
		}

		lhs[i] = newLimb
		i += 1
	}

	while ovfl
	{
		if i < lhc
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
				newLimb = newLimb &+ 1
				ovfl = ovfl || newLimb == 0
			}
			else
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], 1)
			}

			lhs[i] = newLimb
		}
		else
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(rhs[i &- pz], 1)
				lhs.append(newLimb)
			}
			else
			{
				lhs.append(1)
				return
			}
		}

		i += 1
	}

	if lhs.count < rhc { lhs += rhs[(i &- pz)..<(rhc &- pz)] }
}



infix operator +° {}
/// Adding Limbs and returning result
private func +°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	lhs +=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Subtracting Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator -=° {}
/// Calculates difference between Limbs in left limb
private func -=°(inout lhs: Limbs, rhs: Limbs)
{
	var rhs = rhs
	// swap to get difference
	if lhs <° rhs { swap(&lhs, &rhs) }

	let rhc = rhs.count
	var ovfl = false

	var i = 0

	// cut first zeros
	while (i < rhc) && (rhs[i] == 0) { i += 1 }

	while i < rhc
	{
		if ovfl
		{
			(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], rhs[i])
			lhs[i] = lhs[i] &- 1
			ovfl = ovfl || lhs[i] == Limb.max
		}
		else
		{
			(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], rhs[i])
		}

		i += 1
	}

	while ovfl
	{
		(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], 1)

		i += 1
	}

	if lhs.count > 1 && lhs.last! == 0 // cut excess zeros if required
	{
		for i in (lhs.count - 2).stride(through: 1, by: -1)
		{
			if lhs[i] != 0
			{
				lhs = Limbs(lhs[0...i])
				return
			}
		}
		lhs = [lhs[0]]
	}
}

/// Calculating difference between Limbs with returning result
infix operator -° {}
private func -°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	lhs -=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for adding BInts
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func +=(inout lhs: BInt, rhs: BInt)
{
	if lhs.sign == rhs.sign
	{
		lhs.limbs +=° rhs.limbs
		return
	}


	let c = rhs.limbs <° lhs.limbs
	lhs.limbs -=° rhs.limbs
	lhs.sign = (rhs.sign && !c) || (lhs.sign && c) // DNF minimization

	if lhs.isZero() { lhs.sign = false }
}

public func +(lhs: BInt, rhs: BInt) -> BInt
{
	var lhs = lhs
	lhs += rhs
	return lhs
}

public func +(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) + rhs }
public func +(lhs: BInt, rhs: Int) -> BInt { return lhs + BInt(rhs) }

public func +=(inout lhs: Int, rhs: BInt) { lhs += (BInt(lhs) + rhs).toInt() }
public func +=(inout lhs: BInt, rhs: Int) { lhs +=  BInt(rhs)                }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for subtracting BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public prefix func -(n: BInt) -> BInt
{
	var n = n
	n.negate()
	return n
}

public func -(lhs: BInt, rhs: BInt) -> BInt
{
	return lhs + -rhs
}

public func -(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) - rhs }
public func -(lhs: BInt, rhs: Int) -> BInt { return lhs - BInt(rhs) }

public func -=(inout lhs: BInt, rhs: BInt) { lhs +=             -rhs          }
public func -=(inout lhs: Int, rhs: BInt)  { lhs  = (BInt(lhs) - rhs).toInt() }
public func -=(inout lhs: BInt, rhs: Int)  { lhs -=         BInt(rhs)         }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Multiply Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

private func multiplyLimb(inout res: Limbs, _ lhs: Limb, _ rhs: Limb)
{
	let (mulLo, overflow) = Limb.multiplyWithOverflow(lhs, rhs)

	if !overflow
	{
		res[0] = mulLo
		if res.count == 2 { res.removeLast() }
		return
	}

	let axbHi = (lhs >> 32) &* (rhs >> 32)
	let axbMi = (lhs & 0xffff_ffff) &* (rhs >> 32)
	let bxaMi = (rhs & 0xffff_ffff) &* (lhs >> 32)
	let axbLo = (lhs & 0xffff_ffff) &* (rhs & 0xffff_ffff)

	let carry =  (axbMi & 0xffff_ffff) &+ (bxaMi & 0xffff_ffff) &+ (axbLo >> 32)
	let mulHi = axbHi &+ (axbMi >> 32) &+ (bxaMi >> 32)         &+ (carry >> 32)

	res[0] = mulLo
	(res.count == 2) ? res[1] = mulHi : res.append(mulHi)

}

private func squareLimb(inout res: Limbs, _ lhs: Limb)
{
	let (mulLo, overflow) = Limb.multiplyWithOverflow(lhs, lhs)

	if !overflow
	{
		res[0] = mulLo
		if res.count == 2 { res.removeLast() }
		return
	}

	let aLo = lhs & 0xffff_ffff
	let aHi = lhs >> 32
	let axaMi = aLo &* aHi

	let carry = (2 &* (axaMi & 0xffff_ffff)) &+ ((aLo &* aLo) >> 32)
	let mulHi = (aHi &* aHi) + (2 &* (axaMi >> 32)) + (carry >> 32)

	res[0] = mulLo
	(res.count == 2) ? res[1] = mulHi : res.append(mulHi)
}

infix operator *° {}
private func *°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var res: Limbs = [0]
	var singleMul: Limbs = [0, 0]
	res.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			multiplyLimb(&singleMul, lhs[l], rhs[r])

			addLimbs(&res, singleMul, rhsPaddingZeroLimbs: l + r)
		}
	}

	return res
}


private func mulModLimbs(lhs: Limbs, _ rhs: Limbs, mod: Limbs) -> Limbs
{
	var res: Limbs = [0]
	var singleMul: Limbs = [0, 0]
	res.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			multiplyLimb(&singleMul, lhs[l], rhs[r])

			addLimbs(&res, singleMul, rhsPaddingZeroLimbs: l + r)
		}
	}

	return res
}


private func mulLimbs(inout addInto res: Limbs, _ lhs: Limbs, _ rhs: Limbs)
{
	var singleMul: Limbs = [0, 0]

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			multiplyLimb(&singleMul, lhs[l], rhs[r])

			addLimbs(&res, singleMul, rhsPaddingZeroLimbs: l + r)
		}
	}
}

// unusually bad performance
// make factorial use this too
// square
postfix operator ^^ {}
private postfix func ^^(lhs: Limbs) -> Limbs
{
	var res: Limbs = [0]
	var singleMul: Limbs = [0, 0]
	res.reserveCapacity(2 * lhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<l
		{
			if lhs[r] == 0 { continue inner }

			multiplyLimb(&singleMul, lhs[l], lhs[r])

			addLimbs(&res, singleMul +° singleMul, rhsPaddingZeroLimbs: l + r)
		}

		squareLimb(&singleMul, lhs[l])

		addLimbs(&res, singleMul, rhsPaddingZeroLimbs: 2 * l) // l == r
	}

	return res
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for multiplying BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func *(lhs: BInt, rhs: BInt) -> BInt
{
	let sign = !(lhs.sign == rhs.sign || lhs.isZero() || rhs.isZero())
	return BInt(sign: sign, limbs: lhs.limbs *° rhs.limbs)
}

public func *(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) * rhs }
public func *(lhs: BInt, rhs: Int) -> BInt { return lhs * BInt(rhs) }

public func *=(inout lhs: BInt, rhs:BInt) { lhs =       lhs  * rhs          }
public func *=(inout lhs: Int, rhs: BInt) { lhs = (BInt(lhs) * rhs).toInt() }
public func *=(inout lhs: BInt, rhs: Int) { lhs =       lhs  * BInt(rhs)    }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Exponentiation of Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

// Exponentiation by squaring
infix operator ^° {}
private func ^°(lhs: Limbs, rhs: Int) -> Limbs
{
	if rhs == 0 { return [1] }
	if rhs == 1 { return lhs }

	var lhs = lhs
	var rhs = rhs
	var y: Limbs = [1]

	while rhs > 1
	{
		if rhs & 1 != 0 { y = y *° lhs }

		lhs = lhs^^
		rhs >>= 1
	}

	return lhs *° y

}



/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for exponentiation of BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func ^(lhs: BInt, rhs: Int) -> BInt
{
	if rhs < 0
	{
		forceException("BInts can't be exponentiated with exponents < 0");
	}

	return BInt(sign: lhs.sign && ((rhs % 2) == 1), limbs: lhs.limbs ^° rhs)
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Modulo for Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator %° {}
private func %°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	if rhs == [0] { forceException("Modulo by zero not allowed") }
	if lhs <° rhs { return lhs }
	if rhs == [1] { return [0] }

	if lhs.count == 1 && rhs.count == 1
	{
		return [lhs[0] % rhs[0]]
	}

	var accList = [rhs]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		// 3 because seems to be fastest
	}

	// iterate through exponents and subract if needed
	for i in (accList.count - 1).stride(through: 0, by: -1) // -1 because last > lhs
	{
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
		}
	}

	return lhs

//	var acc = rhs
//	var t = 0
//
//	while acc <° lhs
//	{
//		acc <<=° 3
//		t += 1
//	}
//
//	if lhs <° acc { acc >>=° 3 }
//
//	for _ in 0..<t
//	{
//		var times = 0
//		while !(lhs <° acc)
//		{
//			lhs -=° acc
//			times += 1
//		}
//
//
//		acc >>=° 3
//	}
//
//	return lhs

}

private func modLimbs(inout lhs: Limbs, _ rhs: Limbs)
{
	if rhs == [0] { forceException("Modulo by zero not allowed") }
	if lhs <° rhs { return }
	if rhs == [1] { lhs = [0]; return }

	if lhs.count == 1 && rhs.count == 1
	{
		lhs[0] %= rhs[0]
		return
	}

	var accList = [rhs]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		// 3 because seems to be fastest
	}

	// iterate through exponents and subract if needed
	for i in (accList.count - 1).stride(through: 0, by: -1) // -1 because last > lhs
	{
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
		}
	}
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for modulo calculations with BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func %(lhs: BInt, rhs: BInt) -> BInt
{
	let limbs = lhs.limbs %° rhs.limbs
	let sign = lhs.sign && limbs != [0]

	return BInt(sign: sign, limbs: limbs)
}

public func %(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) % rhs }
public func %(lhs: BInt, rhs: Int) -> BInt { return lhs % BInt(rhs) }

public func %=(inout lhs: BInt, rhs: BInt)
{
	modLimbs(&lhs.limbs, rhs.limbs)
	lhs.sign = lhs.sign && lhs.limbs != [0]
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Division for Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator /° {}
/// Division with limbs, result is floored to nearest whole number
private func /°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	// cover base cases
	invariant(rhs != [0], "Division by zero")
	if lhs <° rhs { return [0] }
	if rhs == [1] { return lhs }
	if lhs == rhs { return [1] }

	if lhs.count == 1 && rhs.count == 1 // for small numbers
	{
		return [lhs[0] / rhs[0]]
	}

	var accList = [rhs]
	var divList: [Limbs] = [[Limb(1)]]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		divList.append(divList.last! <<° 3)
		// 3 because seems to be fastest
	}

	var div = [Limb(0)]

	// iterate through exponents and subract if needed
	for i in (accList.count - 1).stride(through: 0, by: -1) // -1 because last > lhs
	{
		var times = 0
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
			times += 1
			//div +=° divList[i]
		}
		div +=° (divList[i] *° [Limb(times)])
	}

	return div

//	var acc = rhs
//	var divAdd = [Limb(1)]
//	var t = 0
//
//	while acc <° lhs
//	{
//		acc <<=° 3
//		divAdd <<=° 3
//		t += 1
//	}
//
//	if lhs <° acc { acc >>=° 3; divAdd >>=° 3 }
//
//	var div = [Limb(0)]
//
//	for _ in 0..<t
//	{
//		var times = 0
//		while !(lhs <° acc)
//		{
//			lhs -=° acc
//			times += 1
//		}
//
//		if times != 0
//		{
//			div +=° ([Limb(times)] *° divAdd)
//		}
//
//		divAdd >>=° 3
//		acc >>=° 3
//	}
//	return div
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for division with BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func /(lhs: BInt, rhs:BInt) -> BInt
{
	let limbs = lhs.limbs /° rhs.limbs
	let sign = (lhs.sign != rhs.sign) && limbs != [0]

	return BInt(sign: sign, limbs: limbs)
}

public func /=(inout lhs: BInt, rhs: BInt) { lhs = lhs / rhs }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Comparing Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

// ==° and !=° not required, work by default

/*
Important:
a < b <==> b > a
a <= b <==> b >= a
but:
a < b <==> !(a >= b)
a <= b <==> !(a > b)
*/

infix operator <° {}
private func <°(lhs: Limbs, rhs: Limbs) -> Bool
{
	if lhs.count != rhs.count
	{
		return lhs.count < rhs.count
	}

	for i in (lhs.count - 1).stride(through: 0, by: -1)
	{
		if lhs[i] != rhs[i]
		{
			return lhs[i] < rhs[i]
		}
	}

	return false // case equal
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for comparing BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func ==(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return false }
	return lhs.limbs == rhs.limbs
}

public func !=(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return true }
	return lhs.limbs != rhs.limbs
}

public func <(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign   }
	if lhs.sign { return rhs.limbs <° lhs.limbs }

	return lhs.limbs <° rhs.limbs
}

public func  >(lhs: BInt, rhs: BInt) -> Bool { return rhs < lhs }
public func <=(lhs: BInt, rhs: BInt) -> Bool { return !(rhs < lhs) }
public func >=(lhs: BInt, rhs: BInt) -> Bool { return !(lhs < rhs) }

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
//MARK:    - Pre-implemented optimized math functions
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

private func factRec(left: Int, _ right: Int) -> Limbs
{
	if left >= right - 1
	{
		return [Limb(right)]
	}

	let mid = (left + right) / 2

	return factRec(left, mid) *° factRec(mid, right)

}

public func fact(n: Int) -> BInt
{
	return BInt(limbs: factRec(1, n))
}

private func lucLehMod(n:Int, _ mod: Limbs) -> Limbs
{
	if n == 1 { return [4] %° mod }

	var res: Limbs = [4]

	for _ in 0...(n - 2)
	{
		res = ((res^^) -° [2]) %° mod
	}

	return res
}

public func isMersenne(exp: Int) -> Bool
{
	if exp == 1 { return false }

	let mersenne = (([1] <<° exp) -° [1])
	let luc = lucLehMod(exp - 1, mersenne)

	return luc == [0]
}

public func getMersennes(toExp: Int) -> [Int]
{
	var expList = [3]

	var i = 3
	while expList.last! <= toExp
	{
		expList.append(getPrime(i))
		i += 1
	}

	if expList.last! > toExp { expList.removeLast() }

	var res = [Int]()

	for ele in expList
	{
		if isMersenne(ele)
		{
			res.append(ele)
		}
	}
	return res
}

private func gcdFactors(lhs: Limbs, rhs: Limbs) -> (ax: Limbs, bx: Limbs)
{
	let gcd = euclid(lhs, rhs)

	return (lhs /° gcd, rhs /° gcd)
}

private func euclid(a: Limbs, _ b: Limbs) -> Limbs
{
	var a = a
	var b = b
	while b != [0]
	{
		(a, b) = (b, a %° b)
	}

	return a
}

public func gcd(a:BInt, _ b:BInt) -> BInt
{
	return BInt(limbs: euclid(a.limbs, b.limbs))
}

private func lcmPositive(a: Limbs, _ b: Limbs) -> Limbs
{
	return (a /° euclid(a, b)) *° b
}

public func lcm(a:BInt, _ b:BInt) -> BInt
{
	return BInt(limbs: lcmPositive(a.limbs, b.limbs))
}

public func fib(n:Int) -> BInt
{
	var a: Limbs = [0]
	var b: Limbs = [1]

	for _ in 2...n
	{
		let t = b
		b +=° a
		a = t
	}

	print("Fib count: \(b.count)")
	return BInt(limbs: b)
}

public func permutations(n: Int, _ k: Int) -> BInt
{
	return BInt(limbs: factRec(n - k, n))
}

public func combinations(n: Int, _ k: Int) -> BInt
{
	return BInt(limbs: factRec(n - k, n) /° factRec(1, k))
}

/// Super fast printing of factorials to n!
func printFactBase10By18(n: Int)
{
	var f: Digits = [1]

	for i in 1...n
	{
		f = mulDigits(f, [Digit(i)])
		print(digitsToString(f))
		print("=> \(i)!")
	}
}

func printFactBase2By64(n: Int)
{
	var f: Limbs = [1]

	for i in 1...n
	{
		f = f *° [Limb(i)]

		let a = limbsToString(f)
		print(a)
		print("=> \(i)!")
	}
}

private func factRecbd(left: Int, _ right: Int) -> Digits
{
	if left < right - 1
	{
		let mid = (left + right) / 2

		return mulDigits(factRecbd(left, mid), factRecbd(mid, right))
	}
	else
	{
		return [Digit(right)]
	}
}

public func factbd(n: Int) -> [UInt64]
{
	return factRecbd(1, n)
}



/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/
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
//MARK:    - BDouble
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
/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public struct BDouble:
	IntegerLiteralConvertible,
	FloatLiteralConvertible,
	CustomStringConvertible,
	Comparable,
	Equatable,
	Hashable
{
	var sign = Bool()
	var numerator = Limbs()
	var denominator = Limbs()

	/**
	Inits a BDouble with two Limbs as numerator and denominator

	- Parameters:
	- numerator: The upper part of the fraction as Limbs
	- denominator: The lower part of the fraction as Limbs

	Returns: A new BDouble
	*/

	init(sign: Bool, numerator: Limbs, denominator: Limbs)
	{
		if denominator == [0] || denominator == [] || numerator == []
		{
			forceException("Denominator can't be zero and limbs can't be []")
		}

		self.sign = sign
		self.numerator = numerator
		self.denominator = denominator

		self.minimize()
	}

	init(_ numerator: BInt, over denominator: BInt)
	{
		self.init(
			sign:			numerator.sign != denominator.sign,
			numerator:		numerator.limbs,
			denominator:	denominator.limbs
		)
	}

	init(_ numerator: Int, over denominator: Int)
	{
		self.init(
			sign: (numerator < 0) != (denominator < 0),
			numerator: [UInt64(abs(numerator))],
			denominator: [UInt64(abs(denominator))]
		)
	}

	init(_ numerator: String, over denominator: String)
	{
		self.init(BInt(numerator), over: BInt(denominator))
	}

	public init(_ z: Int)
	{
		self.init(z, over: 1)
	}

	public init(_ d: Double)
	{
		let nStr = String(d)

		if let exp = nStr["e"]
		{
			let beforeExp = String(nStr[0..<exp].characters.filter{ $0 != "." })
			var afterExp = nStr[(exp + 1)..<nStr.characters.count]
			var sign = false

			if let neg = afterExp["-"]
			{
				afterExp = afterExp[(neg + 1)..<afterExp.characters.count]
				sign = true
			}

			if sign
			{
				let den = ["1"] + [Character](count: Int(afterExp)!, repeatedValue: "0")
				self.init(beforeExp, over: String(den))
				return
			}
			else
			{
				let num = beforeExp + String([Character](count: Int(afterExp)!, repeatedValue: "0"))
				self.init(num, over: "1")
				return
			}
		}

		let i = nStr["."]!
		let beforePoint = nStr[0..<i]

		let afterPoint = nStr[(i + 1)..<nStr.characters.count]

		if afterPoint == "0"
		{
			self.init(beforePoint, over: "1")
		}
		else
		{
			let den = ["1"] + [Character](count: afterPoint.characters.count, repeatedValue: "0")
			self.init(beforePoint + afterPoint, over: String(den))
		}
	}

	public init(integerLiteral value: Int)
	{
		self.init(value)
	}

	public init(floatLiteral value: Double)
	{
		self.init(value)
	}

	public var description: String
		{
			let numStr = limbsToString(self.numerator)
			let denStr = limbsToString(self.denominator)

			return (self.sign ? "-" : "") + numStr + (denStr == "1" ? "" : "/" + denStr)
	}

	public var hashValue: Int
		{
			return "\(self.sign)\(self.numerator)\(self.denominator)".hashValue
	}

	public func rawData() -> (sign: Bool, numerator: [UInt64], denominator: [UInt64])
	{
		return (self.sign, self.numerator, self.denominator)
	}

	public func isPositive() -> Bool { return !self.sign }
	public func isNegative() -> Bool { return self.sign }
	public func isZero() -> Bool { return self.numerator == [0] }

	public mutating func negate()
	{
		if !self.isZero()
		{
			self.sign = !self.sign
		}
	}

	public mutating func minimize()
	{
		if self.numerator == [0]
		{
			self.denominator = [1]
			return
		}

		let gcd = euclid(self.numerator, self.denominator)

		if [1] <° gcd
		{
			self.numerator = self.numerator /° gcd
			self.denominator = self.denominator /° gcd
		}
	}
}

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
//MARK:    - BDouble Operators, needs to be more!
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


public func ==(lhs: BDouble, rhs: BDouble) -> Bool
{
	if lhs.sign != rhs.sign { return false }
	if lhs.numerator != rhs.numerator { return false }
	if lhs.denominator != rhs.denominator { return false }

	return true
}

public func !=(lhs: BDouble, rhs: BDouble) -> Bool
{
	return !(lhs == rhs)
}

public func <(lhs: BDouble, rhs: BDouble) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign }

	// more efficient than lcm version
	let ad  = lhs.numerator *° rhs.denominator
	let bc = rhs.numerator *° lhs.denominator

	if lhs.sign { return bc <° ad }

	return ad <° bc
}

public func  >(lhs: BDouble, rhs: BDouble) -> Bool { return rhs < lhs }
public func <=(lhs: BDouble, rhs: BDouble) -> Bool { return !(rhs < lhs) }
public func >=(lhs: BDouble, rhs: BDouble) -> Bool { return !(lhs < rhs) }




public func *(lhs: BDouble, rhs: BDouble) -> BDouble
{
	var res =  BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.numerator,
		denominator:	lhs.denominator *° rhs.denominator
	)

	if res.isZero() { res.sign = false }
	return res
}

func /(lhs: BDouble, rhs: BDouble) -> BDouble
{
	var res =  BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.denominator,
		denominator:	lhs.denominator *° rhs.numerator
	)

	if res.isZero() { res.sign = false }
	return res
}



public func +(lhs: BDouble, rhs: BDouble) -> BDouble
{
	let ad = lhs.numerator *° rhs.denominator
	let bc = rhs.numerator *° lhs.denominator
	let bd = lhs.denominator *° rhs.denominator

	let resNumerator = BInt(sign: lhs.sign, limbs: ad) + BInt(sign: rhs.sign, limbs: bc)

	return BDouble(
		sign: resNumerator.sign && resNumerator.limbs != [0],
		numerator: resNumerator.limbs,
		denominator: bd
	)
}


public prefix func -(n: BDouble) -> BDouble
{
	var n = n
	n.negate()
	return n
}

public func -(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return lhs + -rhs
}

public func abs(lhs: BDouble) -> BDouble
{
	return BDouble(
		sign: false,
		numerator: lhs.numerator,
		denominator: lhs.denominator
	)
}




























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
//MARK:    - Lookup storage for recurring calculations
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

private struct BStorage
{
	// Powers of 2^64 as Digits
	private static var x_2_64_Digits_mem: [Digits] = [[1]]
	private static var zeros_mem = Dictionary<Int, [UInt64]>()

	private static func zeros(i: Int) -> [UInt64]
	{
		if zeros_mem[i] == nil
		{
			zeros_mem[i] = [UInt64](count: i, repeatedValue: 0)
		}

		return zeros_mem[i]!
	}

	private static func x_2_64_Digits(i: Int) -> Digits
	{
		if i < BStorage.x_2_64_Digits_mem.count
		{
			return BStorage.x_2_64_Digits_mem[i]
		}
		
		var t: Digits = [0]
		
		repeat
		{
			mulDigits(addInto: &t, BStorage.x_2_64_Digits_mem.last!, [446_744_073_709_551_616, 18])
			
			BStorage.x_2_64_Digits_mem.append(t)
		}
			while i >= BStorage.x_2_64_Digits_mem.count
		
		return BStorage.x_2_64_Digits_mem[i]
	}
}
