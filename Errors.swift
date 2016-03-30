//
//  Exceptions.swift
//  MathGround
//
//  Created by Marcel Kröker on 15.02.16.
//  Copyright © 2016 Marcel Kröker. All rights reserved.
//

/**
	Crash the program in case of an unfixable error, and print a
	given error message into the console. 
	
	- Parameter errorMessage: Use an expressive error 
	description to find the problem as fast as possible.
*/
public func forceException(errorMessage: String)
{
	print(errorMessage)

	let x: Int? = nil
	_ = x!
}

/**
	Checks a given condition for its correctness, and crashes 
	the program if the conditions is false.

	- Parameter errorMessage: Error description that gets 
	printed into the console.
*/
public func invariant(condition: Bool, _ errorMessage: String)
{
	if !condition
	{
		forceException("Invariant error: " + errorMessage)
	}
}
