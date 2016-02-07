//
//  BInt
//  MathGround
//
//  Created by Marcel Kröker on 03.04.15.
//  Copyright (c) 2015 Blubyte. All rights reserved.
//

typealias Limbs  = [UInt64]
typealias Limb   =  UInt64
typealias Digits = [UInt64]
typealias Digit  =  UInt64

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

private func limbsToString(limbs: Limbs) -> String
{
	var res: Digits = [0]
	var base: Digits = [1]
	var toAdd = limbsToDigits(limbs)

	for i in 0..<limbs.count
	{

		toAdd[i] = mulDigits(toAdd[i], base)
		res = addDigits(res, toAdd[i])

		base = mulDigits(base, [709_551_616, 446_744_073, 18]) // 2^64
	}

	return digitsToString(res)
}

private func limbsToDigits(limbs: Limbs) -> [Digits]
{
	var res = [Digits]()

	for i in 0..<limbs.count
	{
		var uInt = limbs[i]
		var limb_i_Digits = Digits()

		while uInt != 0
		{
			limb_i_Digits.append(uInt % 1_000_000_000)
			uInt /= 1_000_000_000
		}

		res.append(limb_i_Digits)
	}

	return res
}

private func digitsToString(digits: Digits) -> String
{
	var res = ""

	for i in (digits.count - 1).stride(through: 0, by: -1)
	{
		let cutStr = String(digits[i])

		let paddingZeros = String(
			count:			9 - cutStr.characters.count,
			repeatedValue:	Character("0")
		)

		res += ((i == digits.count - 1 ? "" : paddingZeros) + String(digits[i]))
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

private func addDigits(lhs: Digits, _ rhs: Digits) -> Digits
{
	let maxi = max(lhs.count, rhs.count)
	let mini = min(lhs.count, rhs.count)
	let lhc = lhs.count
	let rhc = rhs.count

	var res = Digits()
	res.reserveCapacity(maxi + 1)

	var overflow: Digit = 0

	var i = 0
	while i < mini || overflow == 1
	{
		let lbyte = (i < lhc) ? lhs[i] : 0
		let rbyte = (i < rhc) ? rhs[i] : 0
		let newbyte = lbyte + rbyte + overflow

		if newbyte > 999_999_999
		{
			res.append(newbyte - 1_000_000_000)
			overflow = 1
		}
		else
		{
			res.append(newbyte)
			overflow = 0
		}

		i += 1
	}

	if !(maxi == mini || i >= maxi)
	{
		res += (lhc < rhc ? rhs[i..<maxi] : lhs[i..<maxi])
	}

	return res
}

private func mulDigits(lhs: Digits, _ rhs: Digits) -> Digits
{
	var addBuffer: Digits = [0]
	addBuffer.reserveCapacity(lhs.count + rhs.count)

	var tmp: UInt64 = 0

	for l in 0..<lhs.count
	{
		for r in 0..<rhs.count
		{
			tmp = lhs[l] * rhs[r]

			var tmpDigits = Digits()

			while tmp != 0
			{
				tmpDigits.append(tmp % 1_000_000_000)
				tmp /= 1_000_000_000
			}

			addBuffer = addDigits(addBuffer, Digits(count: l + r, repeatedValue: 0) + tmpDigits)
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
//MARK: - Shift Limbs by 64 bit (by one index in array)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

private func shiftLeft(lhs: Limbs, _ rhs: Int) -> Limbs
{
	return [UInt64](count: rhs, repeatedValue: 0) + lhs
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
	var overflow: Limb = 0
	var newbyte: Limb = 0
	var rbyte: Limb = 0
	var lbyte: Limb = 0

	let lhc = lhs.count
	let rhc = rhs.count
	let (min, max) = lhc <= rhc ? (lhc, rhc) : (rhc, lhc)

	lhs.reserveCapacity(max + 1)

	var i = 0
	while i < min || overflow == 1
	{
		lbyte = (i < lhc) ? lhs[i] : 0
		rbyte = (i < rhc) ? rhs[i] : 0

		newbyte = (lbyte &+ rbyte) &+ overflow

		if newbyte < lbyte || newbyte < rbyte || (lbyte == Limb.max && rbyte == Limb.max)
		{
			overflow = 1
		}
		else
		{
			overflow = 0
		}

		if i < lhs.count
		{
			lhs[i] = newbyte
		}
		else
		{
			lhs.append(newbyte)
		}

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
	var overflow: Limb = 0

	if lhs <° rhs
	{
		swap(&lhs, &rhs) // swap to get difference
	}

	let lhc = lhs.count
	let rhc = rhs.count
	let min = lhc <= rhc ? lhc : rhc

	var rbyte: Limb = 0
	var lbyte: Limb = 0

	var i = 0
	while i < min || overflow == 1
	{
		lbyte = (i < lhc) ? lhs[i] : 0
		rbyte = (i < rhc) ? rhs[i] : 0

		lhs[i] = lbyte &- (rbyte &+ overflow)

		if lhs[i] > lbyte || (rbyte == Limb.max && overflow == 1)
		{
			overflow = 1
		}
		else
		{
			overflow = 0
		}

		i += 1
	}

	if lhs.count > 1 && lhs.last! == 0 // cut excess zeros if required
	{
		for i in (1..<lhs.count).reverse()
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

	for l in 0..<lhs.count
	{
		inner: for r in 0..<rhs.count
		{
			if lhs[l] == 0 || rhs[r] == 0
			{
				continue inner
			}

			if lhs[l] == 1
			{
				addBuffer +=° (Limbs(count: l + r, repeatedValue: 0) + [rhs[r]])
				continue inner
			}

			if rhs[r] == 1
			{
				addBuffer +=° (Limbs(count: l + r, repeatedValue: 0) + [lhs[l]])
				continue inner
			}

			let lhsLo = (lhs[l] << 32) >> 32 // max 2^32 - 1
			let lhsHi = lhs[l] >> 32 // max 2^32 - 1

			let rhsLo = (rhs[r] << 32) >> 32 // max 2^32 - 1
			let rhsHi = rhs[r] >> 32 // max 2^32 - 1

			let one = lhsLo * rhsLo // max 2^64 - 2^33 + 1
			let two = lhsHi * rhsLo // max 2^64 - 2^33 + 1, needs shiftleft by 32
			let thr = (lhsLo * rhsHi) // max 2^64 - 2^33 + 1, needs shiftleft by 32
			let fou = lhsHi * rhsHi	// max 2^64 - 2^33 + 1, needs shiftleft by 64


			var toAdd: Limbs = [0]
			toAdd.reserveCapacity(2)

			if one != 0
			{
				toAdd[0] = one
			}

			if fou != 0
			{
				toAdd.append(fou)
			}

			if two != 0
			{
				if thr != 0 // two != 0, thr != 0
				{
					let twoSL = two << 32 // max 2^64 - 2^32
					let twoSR = two >> 32 // max 2^32 - 1
					let thrSL = thr << 32 // max 2^64 - 2^32
					let thrSR = thr >> 32 // max 2^32 - 1

					if twoSR + thrSR != 0
					{
						toAdd +=° [0, twoSR + thrSR]
					}

					if twoSL != 0
					{
						toAdd +=° [twoSL]
					}

					if thrSL != 0
					{
						toAdd +=° [thrSL]
					}
				}
				else // two != 0, thr == 0
				{
					let twoSL = two << 32 // max 2^64 - 2^32
					let twoSR = two >> 32 // max 2^32 - 1

					if twoSR != 0
					{
						toAdd +=° [0, twoSR]
					}

					if twoSL != 0
					{
						toAdd +=° [twoSL]
					}
				}
			}
			else
			{
				if thr != 0 // two == 0, thr != 0
				{
					let thrSL = thr << 32 // max 2^64 - 2^32
					let thrSR = thr >> 32 // max 2^32 - 1

					if thrSR != 0
					{
						toAdd +=° [0, thrSR]
					}

					if thrSL != 0
					{
						toAdd +=° [thrSL]
					}
				}
			}

			addBuffer +=° (Limbs(count: l + r, repeatedValue: 0) + toAdd)
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

/// Exopnentiation of Limbs, similar to Mergesort to minimize operations
private func powRec(inout n: Limbs, _ left: Int, _ right: Int) -> Limbs
{
	if left < right - 1
	{
		let mid = (left + right) / 2

		return powRec(&n, left, mid) *° powRec(&n, mid, right)
	}

	return n
}

infix operator ^° {}
private func ^°(var lhs: Limbs, rhs: Int) -> Limbs
{
	if rhs < 1 { return [1] }
	if rhs == 2 { return lhs *° lhs }
	return powRec(&lhs, 0, rhs)
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
	for var i = accList.count - 2; i >= 0; i -= 1 // -1 because last > lhs
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

	for var i = accList.count - 2; i >= 0; i -= 1
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
		divList.append(divList.last! *° [8])
		accList.append(divList.last! *° rhs)
	}

	for var i = accList.count - 2; i >= 0; i -= 1
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
	if lhs.count != rhs.count { return false }

	for i in 0..<lhs.count
	{
		if lhs[i] != rhs[i] { return false }
	}
	return true
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

	if lhs.count == 1
	{
		return lhs[0] < rhs[0]
	}

	for var i = lhs.count - 1; i >= 0; i -= 1
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
		res = ((res ^° 2) -° [2]) %° mod
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

	for var i = 3; expList.last! <= toExp; i += 1
	{
		expList.append(getPrime(i))
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

private func extended_euclid(a: Limbs, _ b: Limbs) -> (d: Limbs, s: Limbs, t: Limbs)
{
	if b == [0] { return (a, [1], [0]) }

	let (ds, ss, ts) = extended_euclid(b, a %° b)

	return (ds, ts, ss -° ((a /° b) *° ts))
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


	// change to (sign: Bool, numerator: [UInt32], denominator: [UInt32]) ?

	/**
	Inits a BDouble with two BInt's as numerator and denominator

	- Parameters:
	- numerator: The upper part of the fraction as a BInt
	- denominator: The lower part of the fraction as a BInt

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
