/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Matrix Tests.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 26.10.17.
*   Copyright © 2017 Marcel Kröker. All rights reserved.
*/

import Foundation
#if !SWIFT_PACKAGE
public class MG_Matrix_Tests
{
	static func testSparseMatrix()
	{
		// Make a random sparse matrix

		var M = Matrix<Int>(
			repeating: 0,
			rows: math.random(1...500),
			cols: math.random(1...500)
		)

		for (i, j) in M
		{
			if math.random(0.0...1.0) <= 0.01 { M[i, j] = math.random(1...99) }
		}

		// Now, convert it to a SparseMatrix
		let S = SparseMatrix(M)

		//		print("Dimension: \(M.rows)x\(M.cols)")
		//		print("Sparse kbit: \(S.bitWidth / 1000)")
		//		print("Normal kbit: \(M.bitWidth / 1000)")
		//		let ratio = String(format: "%.1f", Double(M.bitWidth) / Double(S.bitWidth))
		//		print("Matrix needs \(ratio)x more Memory than SparseMatrix")

		for (i, j) in M
		{
			precondition(M[i, j] == S[i, j], "Error: A[\(i), \(j)] != S[\(i), \(j)])")
		}
	}
}
#endif
