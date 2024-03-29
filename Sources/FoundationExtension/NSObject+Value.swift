//
//  NSObject+Value.swift
//  MMLibrary
//
//  Created by zlm on 2019/12/11.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

public extension NSObject {
//    fileprivate var autoArrangeLayoutKey: UInt8 = 0
//    if let handler = objc_getAssociatedObject(self, &autoArrangeLayoutKey) as? MMAutoArrangeLayoutHandler {
//        return handler
//    }
//    let handler = MMAutoArrangeLayoutHandler()
//    handler.sourceView = self
//    objc_setAssociatedObject(self, &autoArrangeLayoutKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//    return handler
    
    // 懒加载方法
    func mm_lazyObject<T: NSObject>(key: UnsafeRawPointer, Class: T.Type, _ block:(() ->T)) -> T {
        if let existView = self.mm_value(key: key) as? T {
            return existView
        }
        let newView = block()
        self.mm_setValue(key: key, value: newView, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newView
    }
    
    func mm_setValue(key: UnsafeRawPointer, value: NSObject?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_COPY_NONATOMIC) {
        objc_setAssociatedObject(self, key, value, policy)
    }
    
    func mm_value(key: UnsafeRawPointer) -> NSObject? {
        if let value = objc_getAssociatedObject(self, key) as? NSObject {
            return value
        }
        return nil
    }
}
