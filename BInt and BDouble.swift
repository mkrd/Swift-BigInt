//
//  BInt
//  MathGround
//
//  Created by Marcel Kröker on 03.04.15.
//  Copyright (c) 2015 Blubyte. All rights reserved.
//

public struct BInt: CustomStringConvertible
{
	/*
	BInt v1.0
	eN := element of natural numbers
	eNo := element of natural numbers plus zero
	eZ := whole numbers
	[] := undefined (error)
	[0] := 0 eNo, defined as positive
	[n] := n eNo
	[n, m, ...] := (n * 2^(0*32) + (m * 2^(1*32) + ...)

	*/

	// Private data storage. A positive sign indicates a negative number
	private var sign = false
	private var bytes = [UInt64]()

	// Initializers

	init(bytes: [UInt64])
	{
		assert(bytes != [], "[] IS FORBIDDEN")
		self.bytes = bytes
	} // init manually without sign (positive by default)

	init(sign: Bool, bytes: [UInt64])
	{
		self.init(bytes: bytes)
		self.sign = sign
	}

	init(_ z: Int)
	{
		if z == Int.min
		{
			self.init(
				sign: true,
				bytes: [UInt64(abs(z + 1)) + 1]
			)
		}
		else
		{
			self.init(
				sign: z < 0,
				bytes: [UInt64(abs(z))]
			)
		}
	}

	init(_ n: UInt)
	{
		self.init(
			bytes: [UInt64(n)]
		)
	}

	init(_ s: String)
	{
		self = stringToBInt(s)
	}

	// Struct functions

	public func toInt() -> Int
	{
		if self.bytes.count == 1
		{
			if self.bytes[0] <= UInt64(Int.max)
			{
				return self.sign ?
					-Int(self.bytes[0]) :
					Int(self.bytes[0])
			}
			else if self.bytes[0] == UInt64(Int.max) + 1 // Int.min
			{
				return -Int(self.bytes[0])
			}
		}

		print("ERROR: NUMBER TOO BIG")
		return 0
	}

	public var description: String
		{
			return (self.sign ? "-" : "") + bytesToString(self.bytes)
	}

	public func rawData() -> (sign: Bool, bytes: [UInt64])
	{
		return (self.sign, self.bytes)
	}

	public func isPositive() -> Bool { return !self.sign }
	public func isNegative() -> Bool { return self.sign }
	public func isZero() -> Bool { return self.bytes == [0] }

	mutating func negate()
	{
		self.sign = !self.sign
	}
}









// Conversion helper functions

private func bytesToString(bytes: [UInt64]) -> String
{
	var res: [UInt8] = [0]
	var base: [UInt8] = [1]

	for i in 0..<bytes.count
	{
		var toAdd: [UInt8] = String(bytes[i]).characters.map{ UInt8(String($0))! }.reverse()

		toAdd = mulStrPos(toAdd, base)
		res = addStrPos(res, toAdd)

		base = mulStrPos(base, [6,1,6,1,5,5,9,0,7,3,7,0,4,4,7,6,4,4,8,1]) // 2^64
	}

	return String(res.map{ Character(String($0)) }.reverse())
}

private func stringToBInt(var str: String) -> BInt
{
	var resSign = false
	var resBytes: [UInt64] = [0]

	if str.substringToIndex(str.startIndex.advancedBy(1)) == "-"
	{
		str = str.substringFromIndex(str.startIndex.advancedBy(1))
		resSign = true
		if str == "0" { resSign = false }
	}

	var base: [UInt64] = [1]

	for ele in str.characters.reverse()
	{
		guard let b = UInt64(String(ele)) else
		{
			print("ERROR IN STRINGTOBYTES")
			return BInt(bytes: [])
		}

		resBytes +=° (base *° [b])
		base = base *° [10]
	}
	return BInt(sign: resSign, bytes: resBytes)
}

// string helper functions

private extension String
{
	subscript (i: Int) -> String
		{
			return String(self[self.startIndex.advancedBy(i)])
	}

	subscript (r: Range<Int>) -> String
		{
			return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
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

func addStrPos(lhs: [UInt8], _ rhs: [UInt8]) -> [UInt8]
{
	let maxi = max(lhs.count, rhs.count)
	let mini = min(lhs.count, rhs.count)
	let lhc = lhs.count
	let rhc = rhs.count

	var res = [UInt8]()
	res.reserveCapacity(maxi + 1)

	var overflow: UInt8 = 0

	var i = 0
	while i < mini || overflow == 1
	{
		let lbyte = (i < lhc) ? lhs[i] : 0
		let rbyte = (i < rhc) ? rhs[i] : 0
		let newbyte = lbyte + rbyte + overflow

		if newbyte > 9
		{
			res.append(newbyte - 10)
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

private func mulStrPos(lhs: [UInt8], _ rhs: [UInt8]) -> [UInt8]
{
	var addBuffer: [UInt8] = [0]
	addBuffer.reserveCapacity(lhs.count + rhs.count)

	var tmp: UInt8 = 0

	for l in 0..<lhs.count
	{
		for r in 0..<rhs.count
		{
			tmp = UInt8(lhs[l]) * UInt8(rhs[r])

			var tmpres = [UInt8]()

			if tmp < 10
			{
				tmpres.append(tmp)
			}
			else
			{
				tmpres.append(tmp % 10)
				tmpres.append(tmp / 10)
			}

			addBuffer = addStrPos(addBuffer, [UInt8](count: l + r, repeatedValue: 0) + tmpres)
		}
	}
	return addBuffer
}


















private func shiftLeft(lhs: [UInt64], _ rhs: Int) -> [UInt64]
{
	return [UInt64](count: rhs, repeatedValue: 0) + lhs
}

private func shiftRight(lhs: [UInt64], _ rhs: Int) -> [UInt64]
{
	if rhs < 1 { return lhs }
	if rhs >= lhs.count { return [0] }

	return Array(lhs[rhs..<lhs.count])
}

public func <<(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		bytes: shiftLeft(lhs.bytes, rhs)
	)
}

public func >>(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(
		bytes: shiftRight(lhs.bytes, rhs)
	)
}
















infix operator +=°  {}
func +=°(inout lhs: [UInt64], rhs: [UInt64])
{ 
	var overflow: UInt64 = 0
	var newbyte: UInt64 = 0
	var rbyte: UInt64 = 0
	var lbyte: UInt64 = 0

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

		if newbyte < lbyte || newbyte < rbyte || (lbyte == UInt64.max && rbyte == UInt64.max)
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
func +°(var lhs: [UInt64], rhs: [UInt64]) -> [UInt64]
{
	lhs +=° rhs
	return lhs
}


// Returns difference: abs(max(a, b)) - abs(min(a, b))
infix operator -=° {}
func -=°(inout lhs: [UInt64], var rhs: [UInt64])
{
	var overflow: UInt64 = 0

	if lhs <° rhs {
		// swap to get difference
		swap(&lhs, &rhs)
	}

	let lhc = lhs.count
	let rhc = rhs.count
	let min = lhc <= rhc ? lhc : rhc

	var rbyte: UInt64 = 0
	var lbyte: UInt64 = 0

	var i = 0
	while i < min || overflow == 1
	{
		lbyte = (i < lhc) ? lhs[i] : 0
		rbyte = (i < rhc) ? rhs[i] : 0

		lhs[i] = lbyte &- (rbyte &+ overflow)

		if lhs[i] > lbyte || (rbyte == UInt64.max && overflow == 1)
		{
			overflow = 1
		}
		else
		{
			overflow = 0
		}

		i += 1
	}

	// cut excess zeros if required
	if lhs.count > 1 && lhs.last! == 0
	{
		for i in (1..<lhs.count).reverse()
		{
			if lhs[i] != 0
			{
				lhs = Array(lhs[0...i])
				return
			}
		}
		lhs = [lhs[0]]
	}
}

infix operator -° {}
func -°(var lhs: [UInt64], rhs: [UInt64]) -> [UInt64]
{
	lhs -=° rhs
	return lhs
}





public func +=(inout lhs: BInt, rhs: BInt)
{
	if lhs.sign == rhs.sign
	{
		// leave sign like before
		lhs.bytes +=° rhs.bytes
	}
	else
	{
		let c = rhs.bytes <° lhs.bytes

		lhs.bytes -=° rhs.bytes
		lhs.sign = (rhs.sign && !c) || (lhs.sign && c) // DNF minimization

		if lhs.bytes == [0] { lhs.sign = false }
	}
}

func +(var lhs: BInt, rhs: BInt) -> BInt
{
	lhs += rhs
	return lhs
}

public func +(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) + rhs }
public func +(lhs: BInt, rhs: Int) -> BInt { return lhs + BInt(rhs) }

public func +=(inout lhs: Int, rhs: BInt) { lhs += (BInt(lhs) + rhs).toInt() }
public func +=(inout lhs: BInt, rhs: Int) { lhs += BInt(rhs) }







public prefix func -(n:BInt) -> BInt
{
	return BInt(sign: !n.sign, bytes: n.bytes)
}

public func -(lhs: BInt, rhs: BInt) -> BInt
{
	return lhs + BInt(sign: !rhs.sign, bytes: rhs.bytes)
}


public func -(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) - rhs }
public func -(lhs: BInt, rhs: Int) -> BInt { return lhs - BInt(rhs) }

public func -=(inout lhs: BInt, rhs: BInt) { lhs += -rhs }
public func -=(inout lhs: Int, rhs: BInt) { lhs = (BInt(lhs) - rhs).toInt() }
public func -=(inout lhs: BInt, rhs: Int) { lhs -= BInt(rhs) }



























// multiply positive
infix operator *° {}
func *°(lhs: [UInt64], rhs: [UInt64]) -> [UInt64]
{
	var addBuffer: [UInt64] = [0]
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
				addBuffer +=° ([UInt64](count: l + r, repeatedValue: 0) + [rhs[r]])
				continue inner
			}

			if rhs[r] == 1
			{
				addBuffer +=° ([UInt64](count: l + r, repeatedValue: 0) + [lhs[l]])
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


			var toAdd: [UInt64] = [0]
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

			addBuffer +=° ([UInt64](count: l + r, repeatedValue: 0) + toAdd)
		}
	}

	return addBuffer
}


public func *(lhs: BInt, rhs: BInt) -> BInt
{
	return BInt(sign: lhs.sign != rhs.sign, bytes: lhs.bytes *° rhs.bytes)
}

public func *(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) * rhs }
public func *(lhs: BInt, rhs: Int) -> BInt { return lhs * BInt(rhs) }

public func *=(inout lhs: BInt, rhs:BInt) { lhs = lhs * rhs }
public func *=(inout lhs: Int, rhs: BInt) { lhs = (BInt(lhs) * rhs).toInt() }
public func *=(inout lhs: BInt, rhs: Int) { lhs = lhs * BInt(rhs) }








private func powRec(inout n: [UInt64], _ left: Int, _ right: Int) -> [UInt64]
{
	if left < right - 1
	{
		let mid = (left + right) / 2

		return powRec(&n, left, mid) *° powRec(&n, mid, right)
	}
	else
	{
		return n
	}
}

infix operator ^° {}
private func ^°(var lhs: [UInt64], rhs: Int) -> [UInt64]
{
	if rhs < 1 { return [1] }
	if rhs == 2 { return lhs *° lhs }
	return powRec(&lhs, 0, rhs)

}

public func ^(lhs: BInt, rhs: Int) -> BInt
{
	return BInt(sign: lhs.sign && ((rhs % 2) == 1), bytes: lhs.bytes ^° rhs)
}












// moduloPositive
infix operator %° {}
private func %°(var lhs: [UInt64], rhs: [UInt64]) -> [UInt64]
{
	if lhs <° rhs {
		return lhs
	}

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

public func %(lhs: BInt, rhs: BInt) -> BInt
{
	return BInt(
		sign: lhs.sign,
		bytes: lhs.bytes %° rhs.bytes
	)
}

public func %(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) % rhs }
public func %(lhs: BInt, rhs: Int) -> BInt { return lhs % BInt(rhs) }

public func %=(inout lhs: BInt, rhs: BInt) { lhs = lhs % rhs }









private func divModPositive(var lhs: [UInt64], _ rhs: [UInt64]) -> (div: [UInt64], mod: [UInt64])
{
	if lhs <° rhs {
		return ([0], lhs)
	}

	var divList: [[UInt64]] = [[1]]
	var accList = [rhs]
	var div: [UInt64] = [0]

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
private func /°(var lhs: [UInt64], rhs: [UInt64]) -> [UInt64]
{
	if lhs <° rhs {
		return [0]
	}

	var divList: [[UInt64]] = [[1]]
	var accList = [rhs]
	var div: [UInt64] = [0]

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

public func /(lhs: BInt, rhs:BInt) -> BInt
{
	return BInt(
		sign: lhs.sign != rhs.sign,
		bytes: lhs.bytes /° rhs.bytes
	)
}

public func /=(inout lhs: BInt, rhs: BInt) { lhs = lhs / rhs }


















infix operator ==° {}
private func ==°(lhs: [UInt64], rhs: [UInt64]) -> Bool
{
	if lhs.count != rhs.count { return false }

	for i in 0..<lhs.count
	{
		if lhs[i] != rhs[i] { return false }
	}
	return true
}

public func ==(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return false }
	return lhs.bytes ==° rhs.bytes
}

public func !=(lhs: BInt, rhs: BInt) -> Bool {
	return !(lhs == rhs)
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
private func <°(lhs: [UInt64], rhs: [UInt64]) -> Bool
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
		if lhs[i] != rhs[i] {
			return lhs[i] < rhs[i]
		}
	}

	return false // case equal
}

public func <(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign && !rhs.sign }

	let res = lhs.bytes <° rhs.bytes

	return lhs.sign ? !(res || !(rhs.bytes <° lhs.bytes)) : res
	/*res == equals(lhs, rhs)*/
}


public func >(lhs: BInt, rhs: BInt) -> Bool {
	return rhs < lhs
}

public func <=(lhs: BInt, rhs: BInt) -> Bool {
	return !(rhs < lhs)
}

public func >=(lhs: BInt, rhs: BInt) -> Bool {
	return !(lhs < rhs)
}










// Math functions



public func fact(n: Int) -> BInt
{
	return BInt(bytes: factRec(1, n))
}

func factRec(left: Int, _ right: Int) -> [UInt64]
{
	if left < right - 1
	{
		let mid = (left + right) / 2

		return factRec(left, mid) *° factRec(mid, right)
	}
	else
	{
		return [UInt64(right)]
	}
}


public func lucLehMod(n:Int, _ mod:[UInt64]) -> [UInt64]
{
	if n == 1 { return [4] %° mod }

	var res: [UInt64] = [4]

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


public func gcdPositive(a: [UInt64], _ b: [UInt64]) -> [UInt64]
{
	if b == [0] { return a }
	return gcdPositive(b, a %° b)
}

public func gcd(a:BInt, _ b:BInt) -> BInt
{
	if b.bytes == [0] { return a }
	return gcd(b, a % b)
}

public func lcm(a:BInt, _ b:BInt) -> BInt
{
	return (a / gcd(a, b)) * b
}

public func lcmPositive(a: [UInt64], _ b: [UInt64]) -> [UInt64]
{
	return (a /° gcdPositive(a, b)) *° b
}

func fib(n:Int) -> BInt
{
	var a: [UInt64] = [0]
	var b: [UInt64] = [1]

	for var i = 2; i <= n; i += 1
	{
		let c = a +° b
		a = b
		b = c
	}

	return BInt(
		bytes: b
	)
}

func permutations(n: Int, _ k: Int) -> BInt {
	var n = BInt(n)
	var answer = n
	for _ in 1..<k {
		n -= 1
		answer *= n
	}
	return answer
}

func combinations(n: Int, _ k: Int) -> BInt {
	return permutations(n, k) / fact(k)
}






























































public struct BDouble: CustomStringConvertible
{
	private var sign = false
	private var numerator = [UInt64]()
	private var denominator = [UInt64]()


	// change to (sign: Bool, numerator: [UInt32], denominator: [UInt32]) ?

	/**
	Inits a BDouble with two BInt's as numerator and denominator

	- Parameters:
	- numerator: The upper part of the fraction as a BInt
	- denominator: The lower part of the fraction as a BInt

	Returns: A new BDouble
	*/

	init(sign: Bool, numerator: [UInt64], denominator: [UInt64])
	{
		if denominator == [0]
		{
			print("ERROR")
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
			numerator:		numerator.bytes,
			denominator:	denominator.bytes
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
			let numStr = bytesToString(self.numerator)
			let denStr = bytesToString(self.denominator)

			return (self.sign ? "-" : "") + numStr + "/" + denStr
	}

	public func rawData() -> (sign: Bool, numerator: [UInt64], denominator: [UInt64])
	{
		return (self.sign, self.numerator, self.denominator)
	}

	public mutating func minimize()
	{
		let gcd = gcdPositive(self.numerator, self.denominator)

		if [1] <° gcd
		{
			self.numerator = self.numerator /° gcd
			self.denominator = self.denominator /° gcd
		}
	}
}


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

	let resNumerator = BInt(sign: lhs.sign, bytes: timesLhs *° lhs.numerator) + BInt(sign: rhs.sign, bytes: timesRhs *° rhs.numerator)

	return BDouble(sign: resNumerator.sign,
		numerator: resNumerator.bytes,
		denominator: lcm
	)
}

func -(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return lhs + BDouble(sign: !rhs.sign, numerator: rhs.numerator, denominator: rhs.denominator)
}
