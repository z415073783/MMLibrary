//
//  NotificationCenter+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
extension NotificationCenter {
    public func MMaddObserver(target:NSObject, name: NSNotification.Name, block: @escaping MMNotificationBlock) {
        MMNotification.addObserverNotification(target: target, name: name, block: block)
    }
    
    public func MMremoveObserver(target: NSObject) {
        MMNotification.removeObserverNotification(target: target)
    }
    public func MMremoveSelectNotification(name: Notification.Name, target: NSObject) {
        MMNotification.removeSelectObserverNotification(name: name, target: target)
    }

}
