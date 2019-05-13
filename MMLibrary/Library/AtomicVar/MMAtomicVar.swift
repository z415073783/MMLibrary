//
//  MMAtomicVar.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

/// 线程安全var，初始化不要用lazy
public class MMAtomicVar<DataType: Any>: NSObject {
    
    /// 构造方法
    ///
    /// - Parameters:
    ///   - value: 值
    ///   - setTimeout: set超时时间
    ///   - getTimeout: get超时时间
    ///   - didSetAction: 完成set操作回调
    public init(_ value: DataType? = nil,
                setTimeout: TimeInterval = 0,
                getTimeout: TimeInterval = 0.1,
                didSet didSetAction: ((DataType?) -> Void)? = nil) {
        super.init()
        self.setTimeout = setTimeout
        self.getTimeout = getTimeout
        set(value)
        self.didSetAction = didSetAction
    }
    
    
    public func set(_ newValue: DataType?) {
        value = newValue
    }
    
    private func didSet(_ value: DataType?) {
        didSetAction?(value)
    }
    
    
    public func get() -> DataType? {
        return value
    }
    
    
    public func update(_ action: ((inout DataType?) -> Void)) {
        var value = self.value
        action(&value)
        self.value = value
    }
    
    private var didSetAction: ((DataType?) -> Void)?
    
    private var _value: DataType?
    private var value: DataType? {
        set {
            tryLock(atomicLock, {
                _value = newValue
            }, timeout: setTimeout, timeoutAction: nil)
            
            didSet(value)
        }
        get {
            var returnValue: DataType?
            tryLock(atomicLock, {
                returnValue = _value
            }, timeout: getTimeout, timeoutAction: nil)
            return returnValue
        }
    }
    
    private(set) public var setTimeout: TimeInterval = 0
    private(set) public var getTimeout: TimeInterval = 0.1
    
    private let atomicLock = NSLock()
    
    private func tryLock(_ lock: NSLock,
                         _ action: (() -> Void),
                         timeout: TimeInterval = 0,
                         timeoutAction: (() -> Void)?) {
        if timeout > 0 {
            let isGetLock = lock.lock(before: Date(timeIntervalSinceNow: timeout))
            
            if isGetLock {
                action()
                lock.unlock()
            }
            else {
                timeoutAction?()
            }
        }
        else {
            lock.lock()
            action()
            lock.unlock()
        }
    }
}
