//
//  MMProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/8/8.
//

import Foundation

public class MMProtocol<T: NSObject>: NSObject {
    
    var protocolMap: NSMapTable<T, T> = NSMapTable<T, T>.strongToWeakObjects()
    
    var lock: NSLock = NSLock()
    
    public func addProtocol(target: T) {
        lock.lock()
        var isExist = false
        if let existObject = protocolMap.object(forKey: target) {
            isExist = true
        }
        if isExist == false {
            protocolMap.setObject(target, forKey: target)
        }
        lock.unlock()
    }
    
    public func removeProtocol(target: T) {
        lock.lock()
        protocolMap.setObject(nil, forKey: target)
        lock.unlock()
    }

    // perform调用的方法需要添加 @objc 标识才能被识别
    public func perform(_ selector: Selector, object: Any? = nil) {
        lock.lock()
        let list = protocolMap.objectEnumerator()?.allObjects as? [NSObject]
        lock.unlock()
        list?.forEach({ item in
            if let object = object {
                item.perform(selector, with: object)
            } else {
                item.perform(selector)
            }
        })
    }
    // perform调用的方法需要添加 @objc 标识才能被识别
    public func perform(selectorName: String, object: Any? = nil) {
        lock.lock()
        let list = protocolMap.objectEnumerator()?.allObjects as? [NSObject]
        lock.unlock()
        let selector = NSSelectorFromString(selectorName)
        list?.forEach({ item in
            if let object = object {
                item.perform(selector, with: object)
            } else {
                item.perform(selector)
            }
        })
    }
    
}
