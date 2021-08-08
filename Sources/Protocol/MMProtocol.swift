//
//  MMProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/8/8.
//

import Foundation

public class MMProtocol<T: NSObject> {
    var protocolList: [T] = []
    var lock: NSLock = NSLock()
    
    func addProtocol(target: T) {
        lock.lock()
        var isExist = false
        protocolList.forEach { item in
            if item == target {
                isExist = true
                return
            }
        }
        if isExist == false {
            protocolList.append(target)
        }
        lock.unlock()
    }
    
    func removeProtocol(target: T) {
        if isPerforming {
            MMAssert.fire("当前正在执行perform命令, 不能执行remove")
            return
        }
        lock.lock()
        for i in (0 ..< protocolList.count).reversed() {
            let item = protocolList[i]
            if item == target {
                protocolList.remove(at: i)
            }
        }
        lock.unlock()
    }
    var isPerforming = false
    func perform(selector: Selector, object: Any? = nil) {
        isPerforming = true
        protocolList.forEach { item in
            if item.responds(to: selector) {
                if let object = object {
                    item.perform(selector, with: object)
                } else {
                    item.perform(selector)
                }
            }
        }
        isPerforming = false
    }
    
    
    
    
    
}
