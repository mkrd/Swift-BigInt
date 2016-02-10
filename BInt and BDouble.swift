//
//  BInt
//  MathGround
//
//  Created by Marcel Kröker on 03.04.15.
//  Copyright (c) 2015 Blubyte. All rights reserved.
//

typealias Limbs  = [uint_fast64_t]
typealias Limb   =  uint_fast64_t
typealias Digits = [uint_fast64_t]
typealias Digit  =  uint_fast64_t

//MARK: - BInt
public struct BInt: CustomStringConvertible
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
		guard limbs != [] else
		{
			forceException("BInt can't be initialized with limbs == []")
			return
		}

		self.sign = false
		self.limbs = limbs
	}

	init(sign: Bool, limbs: Limbs)
	{
		self.init(
			limbs: limbs
		)

		self.sign = sign
	}

	init(_ z: Int)
	{
		if z == Int.min
		{
			self.init(
				sign: true,
				limbs: [Limb(abs(z + 1)) + 1]
			)
		}
		else
		{
			self.init(
				sign: z < 0,
				limbs: [Limb(abs(z))]
			)
		}
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
			else if self.limbs[0] == Limb(Int.max) + 1 // Int.min
			{
				return -Int(self.limbs[0])
			}
		}

		forceException("Error: BInt too big for conversion to Int")
		return -1 // never reached
	}

	public var description: String
	{
		return (self.sign ? "-" : "") + limbsToString(self.limbs)
	}

	public func rawData() -> (sign: Bool, limbs: [UInt64])
	{
		return (self.sign, self.limbs)
	}

	public func isPositive() -> Bool { return !self.sign }
	public func isNegative() -> Bool { return self.sign }
	public func isZero() -> Bool { return self.limbs == [0] }

	mutating func negate()
	{
		self.sign = !self.sign
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
//MARK:    - Break program in case of unfixable error
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

private func forceException(text: String)
{
	print(text)

	let x: Int? = nil
	_ = x!
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
//MARK:    - Helpful String extensions for easier code
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

private extension String
{
	subscript (i: Int) -> String
	{
		return String(self[self.startIndex.advancedBy(i)])
	}

	subscript (r: Range<Int>) -> String
	{
		return substringWithRange(
			startIndex.advancedBy(r.startIndex)..<startIndex.advancedBy(r.endIndex)
		)
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

let DigitBase: Digit =     1_000_000_000_000_000_000
let DigitHalfBase: Digit =             1_000_000_000
let DigitMax:  Digit =       999_999_999_999_999_999
let DigitZeros =                                  18

private func limbsToString(limbs: Limbs) -> String
{
	var res: Digits = [0]

	for i in 0..<limbs.count
	{
		let toAdd = mulDigits(limbToDigits(limbs[i]), BStorage.x_2_64_Digits(i))
		addDigitsInout(&res, toAdd)
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
	var res = ""

	for i in (digits.count - 1).stride(through: 0, by: -1)
	{
		let cutStr = String(digits[i])

		if i == digits.count - 1
		{
			res += String(digits[i])
		}
		else
		{
			let paddingZeros = String(
				count: DigitZeros - cutStr.characters.count,
				repeatedValue: Character("0")
			)

			res += (paddingZeros + String(digits[i]))
		}
	}

	return res
}

private func stringToBInt(var str: String) -> BInt
{
	var resSign = false
	var reslimbs: Limbs = [0]

	if str.substringToIndex(str.startIndex.advancedBy(1)) == "-"
	{
		str = str.substringFromIndex(str.startIndex.advancedBy(1))
		resSign = true
		if str == "0" { resSign = false }
	}

	var base: Limbs = [1]

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


private func addDigitsInout(inout lhs: Digits, _ rhs: Digits)
{
	var overflow: Digit = 0
	var newbyte: Digit = 0
	var rbyte: Digit = 0
	var lbyte: Digit = 0

	let lhc = lhs.count
	let rhc = rhs.count
	let (min, max) = lhc <= rhc ? (lhc, rhc) : (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = 0

	// cut zeros
	while i < rhc
	{
		if rhs[i] == 0
		{
			if i >= lhc { lhs.append(0) }
			i += 1
		}
		else
		{
			break
		}
	}

	while i < min || overflow == 1
	{
		lbyte = (i < lhc) ? lhs[i] : 0
		rbyte = (i < rhc) ? rhs[i] : 0

		newbyte = (lbyte + rbyte) + overflow

		if newbyte > DigitMax
		{
			if i < lhs.count
			{
				lhs[i] = newbyte - DigitBase
			}
			else
			{
				lhs.append(newbyte - DigitBase)
			}

			overflow = 1
		}
		else
		{
			if i < lhs.count
			{
				lhs[i] = newbyte
			}
			else
			{
				lhs.append(newbyte)
			}

			overflow = 0
		}

		i += 1
	}

	if lhs.count < rhc && i < max
	{
		lhs += rhs[i..<max]
	}
}

private func mulDigits(lhs: Digits, _ rhs: Digits) -> Digits
{
	var addBuffer: Digits = [0]
	addBuffer.reserveCapacity(lhs.count + rhs.count)

	var toAdd: Digits = [0]
	addBuffer.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			let aLo = lhs[l] % DigitHalfBase
			let aHi = lhs[l] / DigitHalfBase
			let bLo = rhs[r] % DigitHalfBase
			let bHi = rhs[r] / DigitHalfBase

			let A = aHi &* bHi
			let B = aLo &* bLo
			let K = (aHi * bLo) + (bHi * aLo)

			if A != 0
			{
				addDigitsInout(&toAdd, Digits(count: r + 1, repeatedValue: 0) + [A])
			}
			if B != 0
			{
				addDigitsInout(&toAdd, Digits(count: r, repeatedValue: 0) + [B])
			}

			if K != 0
			{
				let kLo = (K % DigitHalfBase) * DigitHalfBase
				let kHi = K / DigitHalfBase

				if kLo != 0
				{
					addDigitsInout(&toAdd, Digits(count: r, repeatedValue: 0) + [kLo])
				}

				if kHi != 0
				{
					addDigitsInout(&toAdd, Digits(count: r + 1, repeatedValue: 0) + [kHi])
				}
			}
		}
		addDigitsInout(&addBuffer, Digits(count: l, repeatedValue: 0) + toAdd)
		toAdd = [0]
	}
	return addBuffer
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

private func shiftLeft(lhs: Limbs, _ rhs: Int) -> Limbs
{
	return Limbs(count: rhs, repeatedValue: 0) + lhs
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
		limbs: shiftLeft(lhs.limbs, rhs)
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

infix operator +=°  {}
/// Add limbs and wirte result in left Limbs
private func +=°(inout lhs: Limbs, rhs: Limbs)
{
	var overflow: Bool = false
	var overflowTwo: Bool = false

	var newbyte: Limb = 0
	var rbyte: Limb = 0
	var lbyte: Limb = 0

	let (lhc, rhc) = (lhs.count, rhs.count)

	let (min, max) = lhc <= rhc
		? (lhc, rhc)
		: (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = 0

	 //cut first zeros
	while i < rhc
	{
		if rhs[i] == 0
		{
			if i >= lhc { lhs.append(0) }
			i += 1
		}
		else
		{
			break
		}
	}

	while i < min || overflow
	{
		rbyte = (i < rhc) ? rhs[i] : 0
		lbyte = (i < lhc) ? lhs[i] : 0

		if overflow
		{
			(newbyte, overflow) = Limb.addWithOverflow(lbyte, rbyte)
			(newbyte, overflowTwo) = Limb.addWithOverflow(newbyte, 1)
			overflow = overflow || overflowTwo
		}
		else
		{
			(newbyte, overflow) = Limb.addWithOverflow(lbyte, rbyte)
		}

		i < lhc ? lhs[i] = newbyte : lhs.append(newbyte)

		i += 1
	}

	if lhs.count < rhc && i < max
	{
		lhs += rhs[i..<max]
	}
}

infix operator +° {}
/// Adding Limbs with returning result
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
	var overflow: Bool = false
	var overflowTwo: Bool = false
	var rbyte: Limb = 0

	if lhs <° rhs
	{
		swap(&lhs, &rhs) // swap to get difference
	}

	let lhc = lhs.count
	let rhc = rhs.count
	let min = lhc <= rhc ? lhc : rhc

	var i = 0

	// cut first zeros
	while i < rhc
	{
		if rhs[i] == 0
		{
			i += 1
		}
		else
		{
			break
		}
	}

	while i < min || overflow
	{
		rbyte = (i < rhc) ? rhs[i] : 0

		if overflow
		{
			(lhs[i], overflow) = Limb.subtractWithOverflow(lhs[i], rbyte)
			(lhs[i], overflowTwo) = Limb.subtractWithOverflow(lhs[i], 1)
			overflow = overflow || overflowTwo
		}
		else
		{
			(lhs[i], overflow) = Limb.subtractWithOverflow(lhs[i], rbyte)
		}

		i += 1
	}

	if lhs.count > 1 && lhs.last! == 0 // cut excess zeros if required
	{
		for i in (lhs.count - 1).stride(through: 1, by: -1)
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
		// leave sign like before
		lhs.limbs +=° rhs.limbs
	}
	else
	{
		let c = rhs.limbs <° lhs.limbs

		lhs.limbs -=° rhs.limbs
		lhs.sign = (rhs.sign && !c) || (lhs.sign && c) // DNF minimization

		if lhs.limbs == [0] { lhs.sign = false }
	}
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

public prefix func -(n:BInt) -> BInt
{
	return BInt(sign: !n.sign, limbs: n.limbs)
}

public func -(lhs: BInt, rhs: BInt) -> BInt
{
	return lhs + BInt(sign: !rhs.sign, limbs: rhs.limbs)
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

infix operator *° {}
private func *°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var addBuffer: Limbs = [0]
	addBuffer.reserveCapacity(lhs.count + rhs.count)

	outer: for l in 0..<lhs.count
	{
		if lhs[l] == 0 { continue outer }

		inner: for r in 0..<rhs.count
		{
			if rhs[r] == 0 { continue inner }

			let (mulLo, overflow) = Limb.multiplyWithOverflow(lhs[l], rhs[r])

			if overflow
			{
				let aLo = lhs[l] & 0xffff_ffff
				let aHi = lhs[l] >> 32
				let bLo = rhs[r] & 0xffff_ffff
				let bHi = rhs[r] >> 32

				let axbHi = aHi * bHi
				let axbMi = aHi * bLo
				let bxaMi = bHi * aLo
				let axbLo = aLo * bLo

				let carryBit = (
					(axbMi & 0xffff_ffff)
					 + (bxaMi & 0xffff_ffff)
					 + (axbLo >> 32)
					) >> 32

				let mulHi = axbHi + (axbMi >> 32) + (bxaMi >> 32) + carryBit

				addBuffer +=° (Limbs(count: l + r, repeatedValue: 0) + [mulLo, mulHi])
			}
			else
			{
				addBuffer +=° (Limbs(count: l + r, repeatedValue: 0) + [mulLo])
			}
		}
	}

	return addBuffer
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
	return BInt(sign: lhs.sign != rhs.sign, limbs: lhs.limbs *° rhs.limbs)
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

	if rhs % 2 == 0
	{
		return (lhs *° lhs) ^° (rhs >> 1)
	}
	else
	{
		return lhs *° ((lhs *° lhs) ^° (rhs >> 1))
	}
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
		return BInt(0)
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
	if lhs <° rhs { return lhs }

	var accList = [rhs]

	// get maximum required exponent size
	while !(lhs <° accList.last!) // accList[maxPow] <= lhs
	{
		accList.append(accList.last! *° [16])
		// 16 because seems to be fastest
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
	return BInt(
		sign: lhs.sign,
		limbs: lhs.limbs %° rhs.limbs
	)
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
		divList.append(divList.last! *° [16])
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
	if lhs <° rhs { return [0] }

	var divList: [Limbs] = [[1]]
	var accList = [rhs]
	var div: Limbs = [0]

	while !(lhs <° accList.last!)
	{
		divList.append(divList.last! *° [16])
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
	return BInt(
		sign: lhs.sign != rhs.sign,
		limbs: lhs.limbs /° rhs.limbs
	)
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

infix operator ==° {}
private func ==°(lhs: Limbs, rhs: Limbs) -> Bool
{
	return lhs == rhs
}

infix operator !=° {}
private func !=°(lhs: Limbs, rhs: Limbs) -> Bool
{
	return lhs != rhs
}

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
	return lhs.limbs ==° rhs.limbs
}

public func !=(lhs: BInt, rhs: BInt) -> Bool { return !(lhs == rhs) }

public func <(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign && !rhs.sign }

	let res = lhs.limbs <° rhs.limbs

	return lhs.sign ? !(res || !(rhs.limbs <° lhs.limbs)) : res
	/*res == equals(lhs, rhs)*/
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
	if left < right - 1
	{
		let mid = (left + right) / 2

		return factRec(left, mid) *° factRec(mid, right)
	}
	else
	{
		return [Limb(right)]
	}
}

public func fact(n: Int) -> BInt
{
	return BInt(limbs: factRec(1, n))
}

private func lucLehMod(n:Int, _ mod: Limbs) -> Limbs
{
	if n == 1 { return [4] %° mod }

	var res: Limbs = [4]

	for _ in 0..<(n - 1)
	{
		res = ((res *° res) -° [2]) %° mod
	}

	return res
}

public func isMersenne(exp: Int) -> Bool
{
	if exp == 1 { return false }

	let mersenne = (([2] ^° exp) -° [1])
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
func printfac10(n: Int)
{
	var f: Digits = [1]

	for i in 2...n
	{
		print(digitsToString(f))
		print("=> \(i-1)!")

		f = mulDigits(f, [Digit(i)])
	}
}

func printFact2(n: Int)
{
	var f: Limbs = [1]

	for i in 2...n
	{
		let a = limbsToString(f)
		print(a)
		print("=> \(i-1)!")

		f = f *° [Limb(i)]
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

public struct BDouble: CustomStringConvertible
{
	private var sign = Bool()
	private var numerator = Limbs()
	private var denominator = Limbs()

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
			return
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
		self.init(BInt(numerator), over: BInt(denominator))
	}

	init(_ numerator: String, over denominator: String)
	{
		self.init(BInt(numerator), over: BInt(denominator))
	}

	init(_ n: Int)
	{
		self.init(n, over: 1)
	}

	init(_ n: Double)
	{
		let nStr = String(n)

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

	public var description: String
	{
		let numStr = limbsToString(self.numerator)
		let denStr = limbsToString(self.denominator)

		return (self.sign ? "-" : "") + numStr + "/" + denStr
	}

	public func rawData() -> (sign: Bool, numerator: [UInt64], denominator: [UInt64])
	{
		return (self.sign, self.numerator, self.denominator)
	}

	public mutating func minimize()
	{
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

public func <(lhs: BDouble, rhs: BDouble) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign && !rhs.sign }

	let lcm = lcmPositive(lhs.denominator, rhs.denominator)

	let timesLhs = lcm /° lhs.denominator
	let timesRhs = lcm /° rhs.denominator

	let res = (timesLhs *° lhs.numerator) <° (timesRhs *° rhs.numerator)

	return lhs.sign ? !(res || !((timesRhs *° rhs.numerator) <° (timesLhs *° lhs.numerator))) : res
}

func *(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.numerator,
		denominator:	lhs.denominator *° rhs.denominator
	)
}

func /(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.denominator,
		denominator:	lhs.denominator *° rhs.numerator
	)
}

func +(lhs: BDouble, rhs: BDouble) -> BDouble
{
	let lcm = lcmPositive(lhs.denominator, rhs.denominator)

	let timesLhs = lcm /° lhs.denominator
	let timesRhs = lcm /° rhs.denominator

	let resNumerator = BInt(sign: lhs.sign, limbs: timesLhs *° lhs.numerator) + BInt(sign: rhs.sign, limbs: timesRhs *° rhs.numerator)

	return BDouble(sign: resNumerator.sign,
	               numerator: resNumerator.limbs,
	               denominator: lcm
	)
}

func -(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return lhs + BDouble(sign: !rhs.sign, numerator: rhs.numerator, denominator: rhs.denominator)
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
