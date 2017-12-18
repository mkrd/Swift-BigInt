/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG IO.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 27.05.16.
*   Copyright © 2016 Marcel Kröker. All rights reserved.
*/

import Foundation

/**
	Stop execution and log keyboard input. Returns input after enter was
	pressed.
*/
public func getKeyboardInput() -> String
{
	let keyboard = FileHandle.standardInput

	let input = String(
		data: keyboard.availableData,
		encoding: String.Encoding.utf8
	)!

	return input.trimmingCharacters(in: CharacterSet(["\n"]))
}

/**
	Stop execution and log keyboard input. Returns input as Int after a vaild
	Integer was entered. Otherwise, it promts the user again until a vaild 
	Integer was entered.
*/
public func getKeyboardInputAsInt() -> Int
{
	while true
	{
		let input = getKeyboardInput()

		if let asInt = Int(input) { return asInt }

		print("Input must be an Integer but was: \"\(input)\"")
		print("Enter a vaild number:")
	}
}
