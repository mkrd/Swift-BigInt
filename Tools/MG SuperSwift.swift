/*
*   ————————————————————————————————————————————————————————————————————————————
*   SuperSwift.swift
*   ————————————————————————————————————————————————————————————————————————————
*   SuperSwift is a file that aims to improve the swift programming language. It
*   adds missing functionality and convenient syntax to make the language more
*   versatile.
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 18.02.2017.
*   Copyright © 2017 Marcel Kröker. All rights reserved.
*/

import Foundation

//
////
//////
//MARK: - Snippets
//////
////
//

/*
	Some snippets are essential to use SuperSwift. It defines some operators that are not 
	typeable (or too hard to find) on a normal keyboard, thus it is recommended to use snippets 
	in your IDE or xcode to have easy access to those operators.
*/

// The cartesian product
// Shortcut: $cp 
// Operator: ><

// The dot product, or scalar product
// Shortcut: $dot
// Operator: •

// The element operator (same functionality as X.contains(y))
// Shortcut: $in
// Operator: ∈

// The not element operator (same functionality as !X.contains(y))
// Shortcut: $notin
// Operator: ∉

//
////
//////
//MARK: - Overview
//////
////
//

/*
	This is an overview of all functionality of SuperSwift.
*/




//
////
//////
//MARK: - Extensions
//////
////
//

public extension String
{
	/// Returns character at index i as String.
	subscript(i: Int) -> String
	{
		return String(self[index(startIndex, offsetBy: i)])
	}

	/// Returns characters in range as string.
	subscript(r: Range<Int>) -> String
	{
		let start = index(startIndex, offsetBy: r.lowerBound)
		let end = index(start, offsetBy: r.upperBound - r.lowerBound)

		return String(self[start..<end])
	}

	// Make this function work with normal ranges.
	mutating func removeSubrange(_ bounds: CountableClosedRange<Int>)
	{
		let start = self.index(self.startIndex, offsetBy: bounds.lowerBound)
		let end   = self.index(self.startIndex, offsetBy: bounds.upperBound)
		self.removeSubrange(start...end)
	}

	// Make this function work with normal ranges.
	mutating func removeSubrange(_ bounds: CountableRange<Int>)
	{
		let start = self.index(self.startIndex, offsetBy: bounds.lowerBound)
		let end   = self.index(self.startIndex, offsetBy: bounds.upperBound)
		self.removeSubrange(start..<end)
	}
}

//
////
//////
//MARK: - Operators
//////
////
//

precedencegroup CartesianProductPrecedence
{
	associativity: left
	lowerThan: RangeFormationPrecedence
}

infix operator >< : CartesianProductPrecedence

/**
	Calculate the cartesian product of two sequences. With a left precedence you can iterate 
	over the product:

		// Will print all numbers from 0000 to 9999
		for (((i, j), k), l) in 0...9 >< 0...9 >< 0...9 >< 0...9
		{
			print("\(i)\(j)\(k)\(l)")
		}


	- Parameter lhs: An array.
	- Parameter rhs: An array.
	- returns: [(l, r)] where l ∈ lhs and r ∈ rhs.
*/
func ><<T1: Any, T2: Any>(lhs: [T1], rhs: [T2]) -> [(T1, T2)]
{
	var res = [(T1, T2)]()

	for l in lhs
	{
		for r in rhs
		{
			res.append((l, r))
		}
	}

	return res
}

func ><(lhs: CountableRange<Int>, rhs: CountableRange<Int>) -> [(Int, Int)]
{
	return lhs.map{$0} >< rhs.map{$0}
}

func ><(lhs: CountableRange<Int>, rhs: CountableClosedRange<Int>) -> [(Int, Int)]
{
	return lhs.map{$0} >< rhs.map{$0}
}

func ><(lhs: CountableClosedRange<Int>, rhs: CountableRange<Int>) -> [(Int, Int)]
{
	return lhs.map{$0} >< rhs.map{$0}
}

func ><(lhs: CountableClosedRange<Int>, rhs: CountableClosedRange<Int>) -> [(Int, Int)]
{
	return lhs.map{$0} >< rhs.map{$0}
}

func ><<T: Any>(lhs: [T], rhs: CountableRange<Int>) -> [(T, Int)]
{
	return lhs >< rhs.map{$0}
}

func ><<T: Any>(lhs: [T], rhs: CountableClosedRange<Int>) -> [(T, Int)]
{
	return lhs >< rhs.map{$0}
}


// Better syntax for contains. Works for sets and arrays

infix operator ∈

func ∈<T: Any>(lhs: T, rhs: Set<T>) -> Bool
{
	return rhs.contains(lhs)
}

func ∈<T: Any & Equatable>(lhs: T, rhs: Array<T>) -> Bool
{
	return rhs.contains(lhs)
}

infix operator ∉

func ∉<T: Any & Equatable>(lhs: T, rhs: Array<T>) -> Bool
{
	return !rhs.contains(lhs)
}

func ∉<T: Any>(lhs: T, rhs: Set<T>) -> Bool
{
	return !rhs.contains(lhs)
}
