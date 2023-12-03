//
//  MMProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/8/8.
//

import Foundation

public class MMProtocol<T: NSObject>: NSObject {
    
    var protocolList: [MMWeakObject<T>] = []
    var lock: NSLock = NSLock()
    
    public func addProtocol(target: T) {
        lock.lock()
        var isExist = false
        protocolList.forEach { item in
            if item.value == target {
                isExist = true
                return
            }
        }
        if isExist == false {
            protocolList.append(MMWeakObject(value: target))
        }
        lock.unlock()
    }
    
    public func removeProtocol(target: T) {
        if isPerforming {
            MMAssert.fire("当前正在执行perform命令, 不能执行remove")
            return
        }
        lock.lock()
        for i in (0 ..< protocolList.count).reversed() {
            let item = protocolList[i]
            if item.value == target {
                protocolList.remove(at: i)
            }
        }
        lock.unlock()
    }
    var isPerforming = false
    // perform调用的方法需要添加 @objc 标识才能被识别
    public func perform(_ selector: Selector, object: Any? = nil) {
        isPerforming = true
        protocolList.forEach { item in
            if ((item.value?.responds(to: selector)) != nil) {
                if let object = object {
                    item.value?.perform(selector, with: object)
                } else {
                    item.value?.perform(selector)
                }
            }
        }
    }
    // perform调用的方法需要添加 @objc 标识才能被识别
    public func perform(selectorName: String, object: Any? = nil) {
        isPerforming = true
        protocolList.forEach { item in
            let selector = NSSelectorFromString(selectorName)
            if ((item.value?.responds(to: selector)) != nil) {
                if let object = object {
                    item.value?.perform(selector, with: object)
                } else {
                    item.value?.perform(selector)
                }
            }
        }
        isPerforming = false
    }
    
}
