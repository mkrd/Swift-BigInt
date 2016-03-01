//
//  BInt
//  MathGround
//
//  Created by Marcel Kröker on 03.04.15.
//  Copyright (c) 2015 Blubyte. All rights reserved.
//

import Foundation

typealias Limbs  = [UInt64]
typealias Limb   =  UInt64
typealias Digits = [UInt64]
typealias Digit  =  UInt64


// FILE DEPENDENCIES:
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
	BInt v1.1

	v1.0:	- Initial Release

	v1.1:	- Improved String conversion, now about 45x faster,
	uses base 10^9 instead of base 10
	- bytes renamed to limbs
	- Uses typealias for limbs and digits

	v1.2:	- Improved String conversion, now about 10x faster,
	switched from base 10^9 to 10^18
	(highest possible base without overflows)
	- Implemented kabasutra multiplication algorithm, about 5x faster
	than previous algorithm
	- Addition is 1.3x faster
	- Addtiton and subtraction omit trailing zeros, algorithms need
	less operations now
	- Implemented exponentiation by squaring
	- New storage (BStorage) for often used results
	- Uses uint_fast64_t instead of UInt64 for Limbs and Digits
	
	v1.3:	- Huge Perfomance increase by skipping padding zeros and new multiplication
	algotithms
	- Printing is now about 10x faster, now on par with GMP (print 1! to 10000!)
	- Some operations now use multiple cores


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

	// private data storage. sign == true <==> Number is negative
	private var sign = Bool()
	private var limbs = Limbs()

	// Initializers



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
		self.init(
			limbs: [Limb(n)]
		)
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
	subscript (i: Int) -> String
	{
		return String(self[self.startIndex.advancedBy(i)])
	}

	subscript (r: Range<Int>) -> String
	{
		let start = startIndex.advancedBy(r.startIndex)
		let end   = start.advancedBy(r.endIndex - r.startIndex)

		return self[Range(start: start, end: end)]
	}

	subscript(char: Character) -> Int?
	{
		if let idx = self.characters.indexOf(char)
		{
			return self.startIndex.distanceTo(idx)
		}
		return nil
	}

	func reverse() -> String
	{
		return String(self.characters.reverse())
	}
}

func zeros(count: Int) -> [UInt64]
{
	return [UInt64](count: count, repeatedValue: 0)
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
	var res: Digits = [0]

	for i in 0..<limbs.count
	{
		let toAdd = mulDigits(limbToDigits(limbs[i]), BStorage.x_2_64_Digits(i))
		addDigits(&res, toAdd)
	}

	return digitsToString(res)
}

private func limbToDigits(var limb: Limb) -> Digits
{
	var res = Digits()

	repeat
	{
		res.append(limb % DigitBase)
		limb /= DigitBase
	}
	while limb != 0

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

private func stringToBInt(var str: String) -> BInt
{
	var resSign = false
	var reslimbs: Limbs = [0]
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

		reslimbs +=° (base *° [b])
		base = base *° [10]
	}

	return BInt(
		sign: resSign,
		limbs: reslimbs
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

private func addDigits(inout lhs: Digits, _ rhs: Digits, rhsPaddingZeros pz: Int = 0)
{
	var overflow = false
	var newbyte: Digit = 0

	let (lhc, rhc) = (lhs.count, rhs.count + pz)
	let (min, max) = lhc <= rhc ? (lhc, rhc) : (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = pz

	if i > lhc { lhs += zeros(i - lhc) }

	while i < min || overflow
	{
		newbyte = ((i < lhc) ? lhs[i] : 0)
			+ ((i < rhc) ? rhs[i - pz] : 0)
			+ (overflow  ? 1 : 0)

		overflow = newbyte >= DigitBase

		if overflow { newbyte -= DigitBase }

		i < lhc ? lhs[i] = newbyte : lhs.append(newbyte)

		i += 1
	}

	if lhs.count < rhc { lhs += rhs[(i - pz)..<(max - pz)] }
}

private func mulDigits(lhs: Digits, _ rhs: Digits) -> Digits
{
	var res: Digits = [0]
	res.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			addDigits(&res, mulDigit(lhs[l], rhs[r]), rhsPaddingZeros: l + r)
		}
	}

	return res
}

private func mulDigit(lhs: Digit, _ rhs: Digit) -> Digits
{
	let (mulLo, overflow) = Digit.multiplyWithOverflow(lhs, rhs)

	if !overflow
	{
		return mulLo < DigitBase ? [mulLo] : [mulLo % DigitBase, mulLo / DigitBase]
	} // From here, lhs * rhs >= 2^64 => res.count == 2

	let aLo = lhs % DigitHalfBase
	let aHi = lhs / DigitHalfBase
	let bLo = rhs % DigitHalfBase
	let bHi = rhs / DigitHalfBase

	let K = (aHi * bLo) + (bHi * aLo)

	let res = [
		(aLo * bLo) + ((K % DigitHalfBase) * DigitHalfBase), // mulLo
		(aHi * bHi) + (K / DigitHalfBase) // mulHi
	]

	if res[0] < DigitBase { return res }

	return [res[0] % DigitBase, res[1] + (res[0] / DigitBase)]
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
//MARK: - Shift Limbs by 64 bit (by one index in array) | Unnecessary?
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

	let zeroCount = rhs / 64
	let shft =  rhs % 64

	var carry: Limb = 0

	for i in 0..<lhs.count
	{
		let c = shft == 0 ? 0 : lhs[i] >> UInt64(64 - shft)

		lhs[i] <<= UInt64(shft)
		lhs[i] += carry
		carry = c
	}

	if carry != 0 { lhs.append(carry) }

	lhs = zeros(zeroCount) + lhs
}

private func <<(var lhs: Limbs, rhs: Int) -> Limbs
{
	lhs <<=° rhs
	return lhs
}

private func shiftRight(lhs: Limbs, _ rhs: Int) -> Limbs
{
	if rhs < 1 { return lhs }
	if rhs >= lhs.count { return [0] }

	return Limbs(lhs[rhs..<lhs.count])
}

public func <<(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		limbs: lhs.limbs << rhs
	)
}

public func >>(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		limbs: shiftRight(lhs.limbs, rhs)
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
	var overflow = (one: false, two: false)

	var newLimb: Limb = 0

	let (lhc, rhc) = (lhs.count, rhs.count)
	let (min, max) = (lhc < rhc) ? (lhc, rhc) : (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = 0

	//cut first zeros
	while i < rhc
	{
		if rhs[i] != 0 { break }

		if i >= lhc { lhs.append(0) }
		i += 1
	}

	while i < min || overflow.one
	{
		if overflow.one
		{
			(newLimb, overflow.one) = Limb.addWithOverflow(
				(i < lhc) ? lhs[i] : 0,
				(i < rhc) ? rhs[i] : 0
			)
			(newLimb, overflow.two) = Limb.addWithOverflow(newLimb, 1)
			overflow.one = overflow.one || overflow.two
		}
		else
		{
			(newLimb, overflow.one) = Limb.addWithOverflow(
				(i < lhc) ? lhs[i] : 0,
				(i < rhc) ? rhs[i] : 0
			)
		}

		i < lhc ? lhs[i] = newLimb : lhs.append(newLimb)

		i += 1
	}

	if lhs.count < rhc { lhs += rhs[i..<max] }
}

private func addLimbs(inout lhs: Digits, _ rhs: Digits, rhsPaddingZeros pz: Int)
{
	var overflow = (one: false, two: false)

	var newLimb: Limb = 0

	let (lhc, rhc) = (lhs.count, rhs.count + pz)
	let (min, max) = (lhc < rhc) ? (lhc, rhc) : (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = pz
	if i > lhc { lhs = lhs + zeros(i - lhc) }

	while i < min || overflow.one
	{
		if overflow.one
		{
			(newLimb, overflow.one) = Limb.addWithOverflow(
				(i < lhc) ? lhs[i] : 0,
				(i < rhc) ? rhs[i - pz] : 0
			)
			(newLimb, overflow.two) = Limb.addWithOverflow(newLimb, 1)
			overflow.one = overflow.one || overflow.two
		}
		else
		{
			(newLimb, overflow.one) = Limb.addWithOverflow(
				(i < lhc) ? lhs[i] : 0,
				(i < rhc) ? rhs[i - pz] : 0
			)
		}

		i < lhc ? lhs[i] = newLimb : lhs.append(newLimb)

		i += 1
	}

	if lhs.count < rhc { lhs += rhs[(i - pz)..<(max - pz)] }
}



infix operator +° {}
/// Adding Limbs and returning result
private func +°(var lhs: Limbs, rhs: Limbs) -> Limbs
{
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
private func -=°(inout lhs: Limbs, var rhs: Limbs)
{
	var overflow = (one: false, two: false)

	if lhs <° rhs
	{
		swap(&lhs, &rhs) // swap to get difference
	}

	let (lhc, rhc) = (lhs.count, rhs.count)
	let min = (lhc < rhc) ? lhc : rhc

	var i = 0

	// cut first zeros
	while i < rhc
	{
		if rhs[i] != 0 { break }
		i += 1
	}

	while i < min || overflow.one
	{
		if overflow.one
		{
			(lhs[i], overflow.one) = Limb.subtractWithOverflow(lhs[i], (i < rhc) ? rhs[i] : 0)
			(lhs[i], overflow.two) = Limb.subtractWithOverflow(lhs[i], 1)
			overflow.one = overflow.one || overflow.two
		}
		else
		{
			(lhs[i], overflow.one) = Limb.subtractWithOverflow(lhs[i], (i < rhc) ? rhs[i] : 0)
		}

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
private func -°(var lhs: Limbs, rhs: Limbs) -> Limbs
{
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

public func +(var lhs: BInt, rhs: BInt) -> BInt
{
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

public prefix func -(var n:BInt) -> BInt
{
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

private func multiplyLimb(lhs: Limb, _ rhs: Limb) -> Limbs
{
	let (mulLo, overflow) = Limb.multiplyWithOverflow(lhs, rhs)

	if !overflow { return [mulLo] }

	let aLo = lhs & 0xffff_ffff
	let aHi = lhs >> 32
	let bLo = rhs & 0xffff_ffff
	let bHi = rhs >> 32

	let axbHi = aHi * bHi
	let axbMi = aLo * bHi
	let bxaMi = bLo * aHi
	let axbLo = aLo * bLo

	let carry = (axbMi & 0xffff_ffff) + (bxaMi & 0xffff_ffff) + (axbLo >> 32)
	let mulHi = axbHi + (axbMi >> 32) + (bxaMi >> 32)         + (carry >> 32)

	return [mulLo, mulHi]
}

private func squareLimb(lhs: Limb) -> Limbs
{
	let (mulLo, overflow) = Limb.multiplyWithOverflow(lhs, lhs)

	if !overflow { return [mulLo] }

	let aLo = lhs & 0xffff_ffff
	let aHi = lhs >> 32
	let axaMi = aLo * aHi

	let carry = (2 * (axaMi & 0xffff_ffff)) + ((aLo * aLo) >> 32)
	let mulHi = (aHi * aHi) + (2 * (axaMi >> 32)) + (carry >> 32)

	return [mulLo, mulHi]
}

infix operator *° {}
private func *°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	if lhs == rhs { return square(lhs) }

	var res: Limbs = [0]
	res.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			addLimbs(&res, multiplyLimb(lhs[l], rhs[r]), rhsPaddingZeros: l + r)
		}
	}

	return res
}

// unusually bad performance
// make factorial use this too
private func square(lhs: Limbs) -> Limbs
{
	var res: Limbs = [0]
	res.reserveCapacity(2 * lhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<l
		{
			if lhs[r] == 0 { continue inner }

			let mul = multiplyLimb(lhs[l], lhs[r])
			addLimbs(&res, mul +° mul, rhsPaddingZeros: l + r)
		}

		addLimbs(&res, squareLimb(lhs[l]), rhsPaddingZeros: 2 * l) // l == r
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
	//return exp(lhs, rhs)

	if rhs == 0 { return [1] }
	if rhs == 1 { return lhs }

	let ls =  rhs >> 1
	let rs =  ls + ((rhs % 2 == 0) ? 0 : 1)

	var lSol = Limbs()
	var rSol = Limbs()

	var lock: Int64 = 2

	parallel(&lock) { lSol = exp(lhs, ls) }
	parallel(&lock) { rSol = exp(lhs, rs) }

	while lock != 0 { usleep(1) }

	return lSol *° rSol
}

private func exp(lhs: Limbs, _ rhs: Int) -> Limbs
{
	if rhs == 0 { return [1] }
	if rhs == 1 { return lhs }

	if rhs % 2 == 0
	{
		return exp(square(lhs), rhs >> 1)
	}

	return lhs *° exp(square(lhs), rhs >> 1)
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
private func %°(var lhs: Limbs, rhs: Limbs) -> Limbs
{
	if rhs == [0]
	{
		forceException("Modulo by zero not allowed")
	}

	if lhs <° rhs { return lhs }

	var accList = [rhs]

	// get maximum required exponent size
	while !(lhs <° accList.last!) // accList[maxPow] <= lhs
	{
		accList.append(accList.last! << 3)
		// 3 because seems to be fastest
	}

	// iterate through exponents and subract if needed
	for i in (accList.count - 2).stride(through: 0, by: -1) // -1 because last > lhs
	{
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
		}
	}

	return lhs
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

public func %=(inout lhs: BInt, rhs: BInt) { lhs = lhs % rhs }

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

/// currently not used, but has potential
private func divModLimbs(var lhs: Limbs, _ rhs: Limbs) -> (div: Limbs, mod: Limbs)
{
	if lhs <° rhs { return ([0], lhs) }

	var divList: [Limbs] = [[1]]
	var accList = [rhs]
	var div: Limbs = [0]

	while !(lhs <° accList.last!)
	{
		divList.append(divList.last! << 4)
		accList.append(divList.last! *° rhs)
	}

	for i in (accList.count - 2).stride(through: 0, by: -1)
	{
		while !(lhs <° accList[i])
		{
			lhs -=° accList[i]
			div +=° divList[i]
		}
	}

	return (div, lhs)
}

infix operator /° {}
/// Division with limbs, result is floored to nearest whole number
private func /°(var lhs: Limbs, rhs: Limbs) -> Limbs
{
	invariant(rhs != [0], "Division by zero")
	if lhs <° rhs { return [0] }

	var divList: [Limbs] = [[1]]
	var accList = [rhs]
	var div: Limbs = [0]

	while !(lhs <° accList.last!)
	{
		divList.append(divList.last! << 4)
		accList.append(divList.last! *° rhs)
	}

	for i in (accList.count - 2).stride(through: 0, by: -1)
	{
		while !(lhs <° accList[i])
		{
			lhs -=° accList[i]
			div +=° divList[i]
		}
	}

	return div
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
		res = (square(res) -° [2]) %° mod
	}

	return res
}

public func isMersenne(exp: Int) -> Bool
{
	if exp == 1 { return false }

	let mersenne = (([1] << exp) -° [1])
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

private func euclid(var a: Limbs, var _ b: Limbs) -> Limbs
{
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
		let c = a +° b
		a = b
		b = c
	}

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

	for i in 2...n
	{
		print(digitsToString(f))
		print("=> \(i-1)!")

		f = mulDigits(f, [Digit(i)])
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

func compare()
{
	var lock: Int64 = 2

	parallel(&lock)
		{
			var x: Limbs = [1]

			for i in 2...10000
			{
				//let a = limbsToString(x)
				print("Limbs: \(i)!")
				x = x *° [Limb(i)]
			}
	}

	parallel(&lock)
		{
			var x: Digits = [1]

			for i in 2...10000
			{
				//let a = digitsToString(x)
				print("Digits: \(i)!")
				x = mulDigits(x, [Digit(i)])
			}
	}

	while lock != 0 { usleep(1) }
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


public prefix func -(var n: BDouble) -> BDouble
{
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

	private static func x_2_64_Digits(i: Int) -> Digits
	{
		if i < BStorage.x_2_64_Digits_mem.count
		{
			return BStorage.x_2_64_Digits_mem[i]
		}
		
		repeat
		{
			BStorage.x_2_64_Digits_mem.append(mulDigits(
				BStorage.x_2_64_Digits_mem.last!,
				[446_744_073_709_551_616, 18]
			))
		}
		while i >= BStorage.x_2_64_Digits_mem.count
		
		return BStorage.x_2_64_Digits_mem[i]
	}
}
