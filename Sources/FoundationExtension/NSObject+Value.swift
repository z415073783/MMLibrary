//
//  NSObject+Value.swift
//  MMLibrary
//
//  Created by zlm on 2019/12/11.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
private var mm_keys_NSObject: [NSObject: [String: UnsafeRawPointer]] = [:]


public extension NSObject {
  
    func mm_setValue(key: String, value: NSObject?) {
        let pointKey: UnsafeRawPointer = UnsafeRawPointer(key)
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
        objc_setAssociatedObject(self, existKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    func mm_value(key: String) -> NSObject? {
        guard let existKey = mm_keys_NSObject[self]?[key] else {
            return nil
        }
        if let value = objc_getAssociatedObject(self, existKey) as? NSObject {
            return value
        }
        return nil
    }
}
