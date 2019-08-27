/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG Storage.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 09.10.16.
*   Copyright © 2016 Marcel Kröker. All rights reserved.
*/

import Foundation


public struct Storage
{
	static func readResource(_ key: String, inBundle: Bundle = Bundle.main) -> String
	{
		if let path = inBundle.path(forResource: "longNumbers", ofType: "json", inDirectory: "Resources")
		{
			let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
			let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
			if let jsonResult = jsonResult as? Dictionary<String, String>
			{
				if let res = jsonResult[key]
				{
					return res
				}
			}
		}
		return ""
	}

	/// Write a datapoint to UserDefaults for the key "key".
	static func write(_ value: Any, forKey key: String)
	{
		UserDefaults.standard.set(value, forKey: key)
		UserDefaults.standard.synchronize()
	}

	/// Read a datapoint from UserDefaults with the key key.
	static func read(forkey key: String) -> Any?
	{
		return UserDefaults.standard.object(forKey: key)
	}

	/// Remove a datapoint from UserDefaults for the key key.
	static func remove(forKey key: String)
	{
		UserDefaults.standard.removeObject(forKey: key)
	}

	/// Print all data stored in the UserDefaults.
	static func printData()
	{
		print(UserDefaults.standard.dictionaryRepresentation())
	}

	///	Load the contents of a txt file from a specified directory, like downloadsDirectory.
	///
	///		loadFileContent(from: .downloadsDirectory, name: "kittens.txt")
	static func loadFileContent(from: FileManager.SearchPathDirectory, name: String) -> String
	{
		let dir = FileManager.default.urls(for: from, in: .userDomainMask).first!
		let path = dir.appendingPathComponent(name)
		let text = try? String(contentsOf: path, encoding: String.Encoding.utf8)
		return text ?? ""
	}

	///	Save the contents of a String to a txt file in a specified directory, like
	///	downloadsDirectory.
	///
	///		loadFileContent(from: .downloadsDirectory, name: "kittens.txt")
	static func saveTxtFile(content: String, to: FileManager.SearchPathDirectory, name: String)
	{
		do
		{
			let dir = FileManager.default.urls(for: to, in: .userDomainMask).first!
			try content.write(
				to: dir.appendingPathComponent(name),
				atomically: false,
				encoding: String.Encoding.utf8
			)
		}
		catch
		{
			print("Couldn't write to \(name) in \(to)")
		}
	}

	///	Save the contents of a String to a txt file in a specified directory, like
	///	downloadsDirectory.
	///
	///		loadFileContent(from: .downloadsDirectory, name: "kittens.txt")
	static func appendToTxtFile(content: String, to: FileManager.SearchPathDirectory, name: String)
	{
		let dir = FileManager.default.urls(for: to, in: .userDomainMask).first!
		let path = dir.appendingPathComponent(name)

		if FileManager.default.fileExists(atPath: path.path) {
			if let fileHandle = try? FileHandle(forUpdating: path) {
				fileHandle.seekToEndOfFile()
				fileHandle.write(content.data(using: .utf8, allowLossyConversion: false)!)
				fileHandle.closeFile()
			}
		}
	}
}
