//
//  NSObject+Value.swift
//  MMLibrary
//
//  Created by zlm on 2019/12/11.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
private var mm_keys_NSObject: [NSObject: [String: UnsafeRawPointer]] = [:]
private var mm_keys_lock = NSLock()
public extension NSObject {
    // 懒加载方法
    func mm_lazyObject<T: NSObject>(key: String = #function, Class: T.Type, _ block:(() ->T)) -> T {
        if let existView = self.mm_value(key: key) as? T {
            return existView
        }
        let newView = block()
        self.mm_setValue(key: key, value: newView, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newView
    }
    
    func mm_setValue(key: String, value: NSObject?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_COPY_NONATOMIC) {
        let pointKey: UnsafeRawPointer = UnsafeRawPointer(key)
        mm_keys_lock.lock()
        let keys = mm_keys_NSObject[self]
        if keys == nil {
            mm_keys_NSObject[self] = [:]
        }
        
        let existKey = mm_keys_NSObject[self]?[key] ?? pointKey
        if value == nil {
            mm_keys_NSObject[self]?[key] = nil
        } else {
            mm_keys_NSObject[self]?[key] = pointKey
        }
        mm_keys_lock.unlock()
        objc_setAssociatedObject(self, existKey, value, policy)
    }
    
    func mm_value(key: String) -> NSObject? {
        mm_keys_lock.lock()
        guard let existKey = mm_keys_NSObject[self]?[key] else {
            mm_keys_lock.unlock()
            return nil
        }
        mm_keys_lock.unlock()
        if let value = objc_getAssociatedObject(self, existKey) as? NSObject {
            return value
        }
        return nil
    }
}
