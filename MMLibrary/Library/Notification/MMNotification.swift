//
//  MMNotification.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

public typealias MMNotificationBlock = (Notification) -> Void
public class MMNotification: NSObject {
    public static let shared = MMNotification()
    override init() {
        super.init()
    }
    //获取对象地址
    public class func getAddressIdentifity(sender: Any) -> String {
        if let address: CVarArg = sender as? CVarArg {
            let targetDes = String(format: "%018p", address)
            return targetDes
        } else if let obj: NSObject = sender as? NSObject {
            return obj.description
        } else {
            MMLOG.error("获取唯一描述ID错误")
            return "0"
        }
    }
    
    
    fileprivate var _observerDic: [String: [Notification.Name:NSObjectProtocol]] = [:]
    public class func addObserverNotification(target:Any, name: NSNotification.Name, block: @escaping MMNotificationBlock) {
        let targetDes = getAddressIdentifity(sender: target)
        
        if shared._observerDic[targetDes] == nil {
            shared._observerDic[targetDes] = [:]
        }
        if shared._observerDic[targetDes]![name] == nil {
            shared._observerDic[targetDes]![name] = NotificationCenter.default.addObserver(forName: name, object: nil, queue: OperationQueue.current, using: block)
        }
    }
    public class func removeSelectObserverNotification(name: Notification
        .Name, target: Any) {
        let targetDes = getAddressIdentifity(sender: target)
        NotificationCenter.default.removeObserver(targetDes, name: name, object: nil)
        guard shared._observerDic[targetDes] != nil else {
            return
        }
        shared._observerDic[targetDes]![name] = nil
        
    }
    //    @objc func getLogicServerNotification(sender: Notification) {
    //        //接收到通知
    //        //获取实际下发的通知名
    //        let name = NSNotification.Name("123123")
    //        NotificationCenter.default.post(name: name, object: sender.object, userInfo: sender.userInfo)
    //    }
    
    public class func removeObserverNotification(target: Any) {
        let targetDes = getAddressIdentifity(sender: target)
        guard let observerList = shared._observerDic[targetDes] else {
            return
        }
        for (_, value) in observerList {
            NotificationCenter.default.removeObserver(value)
        }
        shared._observerDic[targetDes] = nil
    }
    
}
