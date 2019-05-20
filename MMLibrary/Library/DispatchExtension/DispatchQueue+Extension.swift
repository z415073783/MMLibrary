//
//  DispatchQueue+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
public extension DispatchQueue {
    
    /// 异步执行
    ///
    /// - Parameter block: 执行的block
    func MMasync(execute block: @escaping () -> Swift.Void) {
        async {
            block()
        }
    }
}

/// 去掉重复执行操作
///
/// - Parameters:
///   - queueName: 执行的队列名
///   - block: 执行的block
public func MMexecuteNoRepeat(queueName: String, block: @escaping () -> Swift.Void) {
    MMexecuteOnMainThread {
        let queue = MMDispatchQueue.getOperationQueue(withName: queueName, maxCount: 1)
        for operation in queue.operations {
            if operation.isExecuting == false {
                operation.cancel()
            }
        }
        queue.addOperation {
            block()
        }
    }
}


/// 在主线程中执行
///
/// - Parameter block: 执行的block
public func MMexecuteOnMainThread(execute block: @escaping () -> Swift.Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
