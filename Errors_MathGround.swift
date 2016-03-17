//
//  Exceptions.swift
//  MathGround
//
//  Created by Marcel Kröker on 15.02.16.
//  Copyright © 2016 Marcel Kröker. All rights reserved.
//

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

public func forceException(text: String)
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
//MARK:    - Check condition that has to be true at any given time
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

public func invariant(statement: Bool, _ errorMessage: String = "")
{
	if !statement
	{
		let message = "Invariant error: "
		if errorMessage != ""
		{
			forceException(message + errorMessage)
			return
		}
		forceException(message + "unspecified")
	}
}