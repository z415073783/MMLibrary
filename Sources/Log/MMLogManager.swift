//
//  MMLogManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/10/19.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
class MMLogManager {
    static let shared = MMLogManager()
    let queue = MMOperationQueue()
    class func setupListen() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 启动")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 退入后台")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 进入前台")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 活跃")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 非活跃")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 销毁")
            MMLogArchive.shared.fireSaveLog()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: shared.queue) { (_) in
            MMLOG.info("Noti Application: 内存警告")
            MMLogArchive.shared.fireSaveLog()
        }
        
        
    }
    
    
}
