/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Vector Matrix.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 12.02.16.
*   Copyright © 2016 Marcel Kröker. All rights reserved.
*/

import Foundation

protocol NumericType:
	SignedNumeric,
	Comparable
{
	static func /(lhs: Self, rhs: Self) -> Self
}

extension Double: NumericType { }
extension Int: NumericType
{
	public init(floatLiteral value: Double)
	{
		self.init(Int(value))
	}
}

extension BDouble: NumericType {}
extension BInt: NumericType {}




struct Vector<T: NumericType>: CustomStringConvertible, Sequence, IteratorProtocol
{
	var data: Matrix<T>
	var nextR = 0

	mutating func next() -> T?
	{
		if nextR >= data.rows { return nil }

		return data[nextR, 0]
	}

	init(_ data: [T])
	{
		self.data = Matrix<T>(data)
	}

	init(_ data: Matrix<T>)
	{
		if data.cols != 1 { fatalError() }
		self.data = data
	}

	var rows: Int
	{
		return self.data.rows
	}

	var description: String
	{
		return String(describing: self.data)
	}

	subscript(i: Int) -> T
	{
		get
		{
			checkBounds(i)
			return self.data[i, 0]
		}
		set
		{
			checkBounds(i)
			self.data[i, 0] = newValue
		}
	}

	private func checkBounds(_ i: Int)
	{
		precondition(i >= 0 && i < self.data.rows, "Vector index out of bounds")
	}
}

func *<T>(lhs: T, rhs: Vector<T>) -> Vector<T>
{
	return Vector(lhs * rhs.data)
}

func *<T>(lhs: Vector<T>, rhs: Vector<T>) -> T
{
	return (lhs.data.transposed() * rhs.data)[0, 0]
}

func +<T>(lhs: Vector<T>, rhs: Vector<T>) -> Vector<T>
{
	return Vector(lhs.data + rhs.data)
}



struct SparseMatrix<T: NumericType>//: CustomStringConvertible, Sequence, IteratorProtocol
{
	var val: [T]
	var colInd: [Int]
	var rowPtr: [Int]

	var bitWidth: Int
	{
		return 64 * (val.count + colInd.count + rowPtr.count)
	}

	init(_ M: Matrix<T>)
	{
		val = [T]()
		colInd = [Int]()
		rowPtr = [0]

		var nonZeroCount = 0

		for i in 0..<M.rows
		{
			for j in 0..<M.cols
			{
				let m = M[i, j]

				if m != 0
				{
					nonZeroCount += 1

					val.append(M[i, j])
					colInd.append(j)
				}
			}

			rowPtr.append(nonZeroCount)
		}
	}


	subscript(r: Int, c: Int) -> T
		{
		get
		{
			let lowerBound = rowPtr[r]
			let upperBound = rowPtr[r + 1] - 1

			if lowerBound <= upperBound
			{
				for i in lowerBound...upperBound
				{
					if colInd[i] == c { return val[i] }
				}
			}

			return 0
		}
		set
		{
			let lowerBound = rowPtr[r]
			let upperBound = rowPtr[r + 1] - 1

			for i in lowerBound...upperBound
			{
				if colInd[i] == c
				{
					val[i] = newValue
					return
				}
			}
		}
	}
}


struct Matrix<T: NumericType>: CustomStringConvertible, Sequence, IteratorProtocol
{
	var data: [[T]]
	var nextR = 0
	var nextC = 0

	var bitWidth: Int
	{
		return 64 * data.count * data[0].count
	}

	mutating func next() -> (Int, Int)?
	{
		if nextC >= self.cols { return nil }

		defer
		{
			nextR += 1
			if nextR - self.rows == 0
			{
				nextR = 0
				nextC += 1
			}
		}

		return (nextR, nextC)
	}

	var rows: Int
	{
		return self.data.count
	}

	var cols: Int
	{
		return self.data[0].count
	}

	init(_ data: [[T]])
	{
		precondition(!data.isEmpty, "Matrix cannot be empty")

		for i in 1..<data.count
		{
			precondition(
				data[i].count == data[0].count,
				"All rows must have the same length"
			)
		}

		self.data = data
	}

	init(_ vector: Vector<T>)
	{
		self = vector.data
	}

	init(_ vector: [T])
	{
		self.data = vector.map{ [$0] }
	}

	init(repeating: T, rows: Int, cols: Int)
	{
		let data = [[T]](
			repeating: [T](repeating: repeating, count: cols),
			count: rows
		)

		self.init(data)
	}

	init(identity size: Int)
	{
		self.init(repeating: 0, rows: size, cols: size)

		for i in 0..<size
		{
			data[i][i] = 1
		}
	}

	var description: String
	{
		var res = ""

		var strArray = [[String]](
			repeating: [String](repeating: "", count: self.cols),
			count: self.rows
		)

		var colMaxChars = [Int]()

		for c in 0..<self.cols
		{
			var newMax = 0
			for r in 0..<self.rows
			{
				strArray[r][c] = String(describing: self[r, c])
				let rcCount = strArray[r][c].count
				if rcCount > newMax { newMax = rcCount }
			}
			colMaxChars.append(newMax)
		}

		for r in 0..<self.rows
		{
			var rowString = "|"
			for c in 0..<self.cols
			{
				let padLength = (colMaxChars[c] - strArray[r][c].count + 4) / 2
				let trailLength = (colMaxChars[c] - strArray[r][c].count + 1) / 2
				let pad = String(repeating: " ", count: padLength)
				let trail = String(repeating: " ", count: trailLength)

				rowString.append(pad.appending(strArray[r][c]).appending(trail))
			}
			res.append("\(rowString)  |\n")
		}

		return String(res[..<res.endIndex])
	}

	subscript(r: Int, c: Int) -> T
	{
		get
		{
			checkBounds(r, c)
			return data[r][c]
		}
		set
		{
			checkBounds(r, c)
			data[r][c] = newValue
		}
	}

	subscript(r: Int) -> [T]
	{
		get
		{
			checkBounds(r, 0)
			return data[r]
		}
		set
		{
			checkBounds(r, 0)
			self.data[r] = newValue
		}
	}

	subscript(col c: Int) -> [T]
	{
		get
		{
			checkBounds(0, c)
			return self.data.map{ $0[c] }
		}
		set
		{
			checkBounds(0, c)
			for i in 0..<self.cols
			{
				self.data[i][c] = newValue[i]
			}
		}
	}

	private func checkBounds(_ r: Int, _ c: Int)
	{
		precondition(r >= 0 && r < self.rows, "Matrix row out of bounds")
		precondition(c >= 0 && c < self.cols, "Matrix column out of bounds")
	}

	mutating func interchange(_ i: Int, _ j: Int)
	{
		checkBounds(i, 0)
		checkBounds(j, 0)
		self.data.swapAt(i, j)
	}

	func transposed() -> Matrix<T>
	{
		var res = Matrix<T>(repeating: 0, rows: self.cols, cols: self.rows)

		for (i, j) in self
		{
			res[j, i] = self[i, j]
		}

		return res
	}
}





func *<T: NumericType>(v: ArraySlice<T>, u: ArraySlice<T>) -> T
{
	precondition(v.count == u.count, "Vectors do not have the same length")

	return zip(v, u).map({$0.0 * $0.1}).reduce(0, +)
}

func *<T: NumericType>(v: [T], u: [T]) -> T
{
	precondition(v.count == u.count, "Vectors do not have the same length")

	return zip(v, u).map({$0.0 * $0.1}).reduce(0, +)
}

func *<T>(A: Matrix<T>, B: Matrix<T>) -> Matrix<T>
{
	precondition(A.cols == B.rows, "Matrix Multiplication Error! (\(A.rows)x\(A.cols) * \(B.rows)x\(B.cols))")

	var res = Matrix<T>(repeating: 0, rows: A.rows, cols: B.cols)

	for (r, c) in res
	{
		res[r, c] = A[r] * B[col: c]
	}

	return res
}

func *<T>(A: Matrix<T>, v: [T]) -> [T]
{
	precondition(A.cols == v.count, "Matrix Multiplication Error!")

	var res = [T](repeating: 0, count: A.rows)

	for r in 0..<res.count
	{
		res[r] = A[r] * v
	}

	return res
}

func *<T>(t: T, A: Matrix<T>) -> Matrix<T>
{
	var res = A

	for (i, j) in A
	{
		res[i, j] = A[i, j] * t
	}

	return res
}



func elementWiseOperator<T>(_ A: inout Matrix<T>, _ B: Matrix<T>, call: (T, T) -> T)
{
	precondition(
		A.rows == B.rows && A.cols == B.cols,
		"Matrix size not equal Error!"
	)

	for (r, c) in A
	{
		A[r, c] = call(A[r, c], B[r, c])
	}
}


func +=<T>(A: inout Matrix<T>, B: Matrix<T>)
{
	elementWiseOperator(&A, B, call: +)
}

func +<T>(A: Matrix<T>, B: Matrix<T>) -> Matrix<T>
{
	var A = A
	A += B
	return A
}

func -=<T>(A: inout Matrix<T>, B: Matrix<T>)
{
	elementWiseOperator(&A, B, call: -)
}

func -<T>(A: Matrix<T>, B: Matrix<T>) -> Matrix<T>
{
    var A = A
    A -= B
    return A
}


/// Returns diagonal Matrix D, so that A' = D * A equals the equilibrated Matrix, where A' has a row norm of 1 for every row
func equilibrate<T>(_ A: Matrix<T>) -> Matrix<T>
{
	var rowSums = [T](repeating: 0, count: A.rows)

	for r in 0..<A.rows
	{
		rowSums[r] = A[r].reduce(0,{ $0 + abs($1) })
	}

	var D = Matrix<T>(repeating: 0, rows: A.rows, cols: A.cols)

	for i in 0..<rowSums.count
	{
		D[i, i] = (1 / rowSums[i])
	}

	return D
}


func transpose<T>(_ A: Matrix<T>) -> Matrix<T>
{
	var res = Matrix<T>(repeating: 0, rows: A.cols, cols: A.rows)

	for (r, c) in A
	{
		res[c, r] = A[r, c]
	}

	return res
}


/// Performs gauss on A and b
func gauss<T>(_ A: Matrix<T>, _ b: [T]) -> (Matrix<T>, [T])
{
	var A = A
	var b = b
	for piv in 0..<(A.rows - 1)
	{
		if A[piv, piv] == 0 { continue }

		let pivEle = A[piv, piv]

		for eliminate in (piv + 1)..<A.rows
		{
			let multi = A[eliminate, piv] / pivEle

			rowSub(
				&A[eliminate],
				A[piv],
				multi
			)

			b[eliminate] = b[eliminate] - (b[piv] * multi)
		}
	}
	return (A, b)
}

/// Decompose A into L and R, where A = L * R
func LRDecomp<T>(_ A: Matrix<T>) -> (L: Matrix<T>, R: Matrix<T>)
{
	var A = A
	var L = Matrix<T>(identity: A.rows)

	for piv in 0..<(A.rows - 1)
	{
		for elim in (piv + 1)..<A.rows
		{
			L[elim, piv] = A[elim, piv] / A[piv, piv]

			rowSub(&A[elim], A[piv], L[elim, piv])
		}
	}

	return (L, A)
}


func LRDecompPiv<T>(_ A: Matrix<T>) -> (L: Matrix<T>, R: Matrix<T>, P: Matrix<T>)
{
	var A = A
	var P = Matrix<T>(identity: A.rows)

	for piv in 0..<(A.rows - 1)
	{
		var maxRow = piv

		for i in (piv + 1)..<A.rows
		{
			if abs(A[i, piv]) > abs(A[maxRow, piv])
			{
				maxRow = i
			}
		}

		if piv != maxRow
		{
			A.data.swapAt(piv, maxRow)
			P.data.swapAt(piv, maxRow)
		}

		for elim in (piv + 1)..<A.rows
		{
			A[elim, piv] = A[elim, piv] / A[piv, piv]

			for j in (piv + 1)..<A.rows
			{
				A[elim, j] = A[elim, j] - (A[elim, piv] * A[piv, j])
			}
		}
	}

	var L = Matrix<T>(identity: A.rows)

	for i in 0..<A.rows
	{
		for j in 0..<i
		{
			L[i, j] = A[i, j]
			A[i, j] = 0
		}
	}

	return (L, A, P)
}

func LRDecompPivEquil<T>(_ A: Matrix<T>) -> (L: Matrix<T>, R: Matrix<T>, P: Matrix<T>, D: Matrix<T>)
{
	let D = equilibrate(A)
	let (L, R, P) = LRDecompPiv(D * A)

	return (L, R, P, D)
}

func sq<T: NumericType>(_ a: T, _ prec: Int) -> T
{
	if a == 0 { return 0 }

	var n = (1 + a) / 2


	for _ in 0..<prec
	{
		let t0 = (n * n) / a
		n = (n / 2) * (3 - t0)
	}
	return n
	
}




func givens<T>(_ A: Matrix<T>) -> Matrix<T>
{
	var A = A
	var G = [Matrix<T>]()
	for i in 0..<(A.cols - 1)
	{
		for k in (i + 1)..<A.rows
		{
			if A[k, i] == 0 { continue }

			var Gcr = Matrix<T>(identity: A.rows)

			let r = sq((A[k, i] * A[k, i]) + (A[i, i] * A[i, i]), 10)

			let c = A[i, i] / r
			let s = A[k, i] / r

			Gcr[k, k] = c
			Gcr[k, i] = -s
			Gcr[i, k] = s
			Gcr[i, i] = c

			G.append(Gcr)

		}
	}

	for ele in G
	{
		A = ele * A
	}

	return A
}


func solveBackwarts<T>(_ A: Matrix<T>, _ b: [T]) -> [T]
{
	var x = [T](repeating: 0, count: b.count)

	for i in (0..<A.rows).reversed()
	{
		let j = i + 1
		let rowMul = A[i][j..<A.cols] * x[j..<x.count]

		x[i] = (b[i] - rowMul) / A[i, i]
	}

	return x
}

func solveForwards<T>(_ A: Matrix<T>, _ b: [T]) -> [T]
{
	var x = [T](repeating: 0, count: b.count)

	for i in 0..<A.rows
	{
		let rowMul = A[i][0..<i] * x[0..<i]

		x[i] = (b[i] - rowMul) / A[i, i]
	}

	return x
}

func solveLR<T>(_ A: Matrix<T>, _ b: [T]) -> [T]
{
	let (L, R) = LRDecomp(A)

	let y = solveForwards(L, b)

	return solveBackwarts(R, y)
}

func solveGauss<T>(_ A: Matrix<T>, _ b: [T]) -> [T]
{
	let (R, y) = gauss(A, b)

	return solveBackwarts(R, y)
}


func solveLRPD<T>(_ A: Matrix<T>, _ b: [T]) -> [T]
{
	// LRx = PDb, LR = PDA
	let (L, R, P, D) = LRDecompPivEquil(A)

	let y = solveForwards(L, (P  * D) * b)

	return solveBackwarts(R, y)
}



func rowAdd<T: NumericType>(_ modify: inout [T], _ toAdd: [T], _ multiplier: T)
{
	precondition(modify.count == toAdd.count, "Rows have different lengths")

	for i in 0..<modify.count
	{
		modify[i] = modify[i] + (toAdd[i] * multiplier)
	}
}

func rowSub<T: NumericType>(_ modify: inout [T], _ toSub: [T], _ multiplier: T)
{
	precondition(modify.count == toSub.count, "Rows have different lengths")

	for i in 0..<modify.count
	{
		modify[i] = modify[i] - (toSub[i] * multiplier)
	}
}

func rowMul<T: NumericType>(_ row: inout [T], _ multiplier: T)
{
	for i in 0..<row.count
	{
		row[i] = row[i] * multiplier
	}
}
