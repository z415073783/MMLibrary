//
//  MMLogManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/10/19.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif
class MMLogManager {
    static let shared = MMLogManager()
    let queue = MMOperationQueue()
    class func setupListen() {
        func printInfo(sender: Notification) {
            MMLOG.control("Application Notification: \(sender.name)")
            MMLogArchiveManager.shared.fireSaveLogs()
        }
        #if os(iOS) || os(tvOS)
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: shared.queue) { (sender) in
            printInfo(sender: sender)
        }
        #endif
        
    }
}
