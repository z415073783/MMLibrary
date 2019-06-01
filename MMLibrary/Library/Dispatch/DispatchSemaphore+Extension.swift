//
//  DispatchSemaphore+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
extension DispatchSemaphore {
    /// 信号指定等待时间进行等待
    ///
    /// - Parameters:
    ///   - timeoutMillisecond: 等待时间，单位为ms
    ///   - functionName: 函数名
    ///   - fileName: 文件名
    ///   - lineNumber: 代码行号
    /// - Returns: 等待超时结果
    @discardableResult
    public func mm_wait(_ timeoutMillisecond: Int,
                        functionName: String = #function,
                        fileName: String = #file,
                        lineNumber: Int = #line) -> DispatchTimeoutResult {
        let result = wait(timeout: DispatchTime.now() + .milliseconds(timeoutMillisecond))
        if result == .timedOut {
            let lastFileName = fileName.mm_split(".").last ?? ""
            let callInfo = "[\(lastFileName):\(functionName):\(lineNumber)]"
            MMLOG.error("信号量等待超时\(timeoutMillisecond)ms：\(callInfo)")
        }
        return result
    }
    
}
