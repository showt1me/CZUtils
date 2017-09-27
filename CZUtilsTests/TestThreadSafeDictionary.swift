//
//  TestThreadSafeDictionary.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/27/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import XCTest
@testable import CZUtils

class TestThreadSafeDictionary: XCTestCase {
    fileprivate static let queueLabel = "com.tony.test,threadSafeDictionary"
    
    fileprivate var originalDict: [Int: Int] = {
        var originalDict = [Int: Int]()
        for (i, value) in (0 ..< 100000).enumerated() {
            originalDict[i] = value
        }
        return originalDict
    }()
    
    func testInitializerithoutGCD() {
        let threadSafeDict = ThreadSafeDictionary<Int, Int>(dictionary: originalDict)
        XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
    }
    
    func testSetValueWithoutGCD() {
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        for (key, value) in originalDict {
            threadSafeDict[key] = value
        }
        XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
    }
    
    func testSetValueWithGCD() {
        // Initialize ThreadSafeDictionary
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        
        // Concurrent DispatchQueue to simulate multiple-thread read/write executions
        let queue = DispatchQueue(label: TestThreadSafeDictionary.queueLabel,
                                  qos: .userInitiated,
                                  attributes: .concurrent)
        
        // Group asynchonous write operations by DispatchGroup
        let dispatchGroup = DispatchGroup()
        for (key, value) in originalDict {
            dispatchGroup.enter()
            queue.async {
                // Sleep to simulate operation delay in multiple thread mode
                let sleepInternal = TimeInterval((arc4random() % 10)) * 0.000001
                Thread.sleep(forTimeInterval: sleepInternal)
                threadSafeDict[key] = value
//                let actualValue = threadSafeDict[key]
//                XCTAssert(actualValue == value, "actualValue \(actualValue) should equal to originalValue \(value)")
                dispatchGroup.leave()
            }
        }

        // DispatchGroup: Asynchronously wait for completion signal of all operations
        dispatchGroup.notify(queue: .main) {
            XCTAssert(threadSafeDict.isEqual(toDictionary: self.originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
        }
    }
}