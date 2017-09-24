//
//  CZProMutexLock.swift
//
//  Created by Cheng Zhang on 9/19/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

open class CZProMutexLock: NSObject {
    fileprivate var mutex = pthread_mutex_t()
    
    public override init() {
        var attr = pthread_mutexattr_t()
        guard pthread_mutexattr_init(&attr) == 0 else {
            preconditionFailure()
        }
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
        guard pthread_mutex_init(&mutex, &attr) == 0 else {
            preconditionFailure()
        }
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    public func withLock<T>(_ closure: () -> T) -> T {
        defer {
            pthread_mutex_unlock(&mutex)
        }
        pthread_mutex_lock(&mutex)
        return closure()
    }
}
