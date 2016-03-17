//
//  BitField.swift
//  MathGround
//
//  Created by Marcel Kröker on 12.02.16.
//  Copyright © 2016 Marcel Kröker. All rights reserved.
//

struct BitField
{
	var data = [UInt64]()
	var maxIndex = Int()

	init(count: Int, repeated: Bool)
	{
		if count == 0
		{
			forceException("Emtpy Bitfield is not possible to initialize")
		}

		maxIndex = count - 1

		let size = (maxIndex >> 6) + 1
		data = [UInt64](count: size, repeatedValue: repeated ? UInt64.max : 0)
	}

	func atIndex(i: Int) -> UInt64?
	{
		let byte = self.data[i >> 6] & (UInt64(1) << UInt64(i & 0b111_111))
		if byte != 0
		{
			return byte
		}
		return nil
	}

	func get(i: Int) -> Bool
	{
		if i > maxIndex || i < 0
		{
			forceException("BitField out of bounds")
		}

		let byte = self.data[i >> 6] & (UInt64(1) << UInt64(i & 0b111_111))

		return byte != 0
	}

	mutating func set(i: Int, b: Bool)
	{
		if i > maxIndex || i < 0
		{
			forceException("BitField out of bounds")
		}

		if b
		{
			self.data[i >> 6] |= (UInt64(1) << UInt64(i & 0b111_111))
		}
		else
		{
			if let byte = atIndex(i)
			{
				self.data[i >> 6] -= byte
			}
		}
	}
}