/*
*   ————————————————————————————————————————————————————————————————————————————
*   MG QueueDispatch.swift
*   ————————————————————————————————————————————————————————————————————————————
*   Created by Marcel Kröker on 25.12.15.
*   Copyright © 2015 Marcel Kröker. All rights reserved.
*/

import Foundation

public struct QueueDispatch
{
	static var coreCount: Int
	{
		return ProcessInfo.processInfo.activeProcessorCount
	}

	/**
		Run trailing closure after a given time in seconds in background queue.
	*/
	static public func runAfterDelay(_ seconds: Double, _ closure: @escaping () -> ())
	{
		let queue = DispatchQueue.global()

		queue.asyncAfter(deadline: DispatchTime.now() + seconds, execute: closure)
	}

	/**
		Dispatches closures and optionally waits for them to finish their 
		execution before the caller can continue executing his code.
	*/
	static public func parallel(waitUnitAllFinished wait: Bool, closures: [() -> ()])
	{
		let queue = OperationQueue()

		queue.maxConcurrentOperationCount = QueueDispatch.coreCount - (wait ? 0 : 1)

		for closure in closures
		{
			queue.addOperation(closure)
		}

		if wait { queue.waitUntilAllOperationsAreFinished() }
	}
}



