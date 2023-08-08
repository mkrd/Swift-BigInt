/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Complex.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 06.11.16.
*   Copyright © 2016 Marcel Kröker. All rights reserved.
*/

import Foundation

public struct Complex
{
	var (re, im): (Double, Double)

	init(re: Double, im: Double)
	{
		self.re = re
		self.im = im
	}

	var r: Double
	{
		get { return self.re }
		set { self.re = r }
	}

	var i: Double
	{
		get { return self.im }
		set { self.im = i }
	}
}

public func +(lhs: Complex, rhs: Complex) -> Complex
{
	return Complex(
		re: lhs.re + rhs.re,
		im: lhs.im + rhs.im
	)
}

public func -(lhs: Complex, rhs: Complex) -> Complex
{
	return Complex(
		re: lhs.re + rhs.re,
		im: lhs.im + rhs.im
	)
}

public func *(x: Complex, y: Complex) -> Complex
{
	return Complex(
		re: x.re * y.re - x.im * y.im,
		im: x.im * y.re + x.re * y.im
	)
}

public func /(x: Complex, y: Complex) -> Complex
{
	let divisor = y.re * y.re + y.im * y.im
	return Complex(
		re: (x.re * y.re + x.im * y.im) / divisor,
		im: (x.im * y.re - x.re * y.im) / divisor
	)
}

public func exp(_ x: Complex) -> Complex
{
	let ea = Complex(re: pow(2.7, x.re), im: 0.0      )
	let t  = Complex(re: cos(x.im)     , im: sin(x.im))
	return ea * t
}
