//
//  NotificationCenter+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
extension NotificationCenter {
    public func mm_addObserver(target:NSObject, name: NSNotification.Name, block: @escaping MMNotificationBlock) {
        MMNotification.addObserverNotification(target: target, name: name, block: block)
    }
    
    public func mm_removeObserver(target: NSObject) {
        MMNotification.removeObserverNotification(target: target)
    }
    public func mm_removeSelectNotification(name: Notification.Name, target: NSObject) {
        MMNotification.removeSelectObserverNotification(name: name, target: target)
    }

}
