//
//  MMDispatchQueue.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation


/// 多线程管理工厂类，管理OperationQueue列表
open class MMDispatchQueue: NSObject {
    
    /// 单例
    static let shared = MMDispatchQueue()
    public override init() {
        super.init()
        //        checkFreeQueue()
    }
    
    fileprivate var allOperationQueueDictionary: [String: MMOperationQueue] {
        set {
            atomicAllOperationQueueDictionary.set(newValue)
        }
        get {
            return atomicAllOperationQueueDictionary.get() ?? [:]
        }
    }
    private var atomicAllOperationQueueDictionary: MMAtomicVar<[String: MMOperationQueue]> = MMAtomicVar([:])
    
    //线程锁
//    private static var _lock: NSRecursiveLock = NSRecursiveLock()
    
//    /// 锁住
//    open class func lock() {
//        YLBasicDispatchManager._lock.lock()
//    }
//
//    /// 解锁
//    open class func unlock() {
//        YLBasicDispatchManager._lock.unlock()
//    }
    //    private let _dispatchQueue = getOperationQueue(withName: "YLBasicDispatchQueue", maxCount: 1)
    public class func getOperationQueue(withName name: String, maxCount: Int, finishBlock: @escaping (_ queue: MMOperationQueue) -> Void) {
        MMexecuteOnMainThread {
            if let queue = shared.allOperationQueueDictionary[name] {
                finishBlock(queue)
            }
            else {
                let queue = MMOperationQueue(maxCount: maxCount)
                queue.name = name
                shared.allOperationQueueDictionary[name] = queue
                finishBlock(queue)
            }
        }
    }
    
    //    let semaphore = DispatchSemaphore(value: 1)
    
    /// 获取指定名字及最大并发数的YLOperationQueue实例
    ///
    /// - Parameters:
    ///   - name: queue的名字
    ///   - maxCount: Queue的最大并发数
    ///   - isFreeQuque: 是否是即时队列
    /// - Returns: YLOperationQueue实例
    public class func getOperationQueue(withName name: String, maxCount: Int, isFreeQuque: Bool = false) -> MMOperationQueue {
        //        _ = YLBasicDispatchManager.shared.semaphore.wait()
        if let queue = shared.allOperationQueueDictionary[name] {
            //            shared.semaphore.signal()
            return queue
        }
        else {
            //            if Thread.isMainThread == false {
            //                YLLOG.info("getOperationQueue方法必须放在主线程中! name = \(name)")
            //                assert(Thread.isMainThread, "getOperationQueue方法必须放在主线程中! name = \(name)")
            //            }
            let queue = MMOperationQueue(maxCount: maxCount)
            queue.name = name
            queue.isFreeQueue = isFreeQuque
            shared.allOperationQueueDictionary[name] = queue
            //            shared.semaphore.signal()
            return queue
        }
    }
    
    //    func checkFreeQueue() {
    //        Timer.scheduledTimerYL(withTimeInterval: 30, repeats: true, block: { (timer) in
    //            ExecuteOnMainThread {
    //                for (key, value) in YLBasicDispatchManager.shared.allOperationQueueDictionary {
    //                    if value.operationCount == 0 {
    //                        YLBasicDispatchManager.shared.allOperationQueueDictionary[key] = nil
    //                    }
    //                }
    //            }
    //        })
    //    }
    
    
    /// 移除指定名字的OperationQueue
    ///
    /// - Parameter name: queue的名字
    public class func removeFreeOperationQueue(name: String) {
        MMexecuteOnMainThread {
            if shared.allOperationQueueDictionary[name] != nil {
                shared.allOperationQueueDictionary[name] = nil
            }
        }
    }
    
    
    /// 移除所有队列中的任务
    public class func removeAllOperations() {
        MMexecuteOnMainThread {
            for (_, queue) in shared.allOperationQueueDictionary.values.enumerated() {
                queue.cancelAllOperations()
            }
        }
        
    }
    
    /// 移除即时队列
    public class func removeFreeOperations() {
        MMexecuteOnMainThread {
            for (_, queue) in shared.allOperationQueueDictionary.values.enumerated() {
                if queue.isFreeQueue {
                    queue.cancelAllOperations()
                }
            }
        }
    }
    
}


public extension MMDispatchQueue {
    /// 下载图片
    class var imageQueue: MMOperationQueue {
        get {
            return getOperationQueue(withName: "YLImageQueue", maxCount: 1)
        }
    }
}

public extension MMDispatchQueue {
    /// 示例queue
    class var testQueue: MMOperationQueue {
        get {
            return getOperationQueue(withName: #function, maxCount: 1, isFreeQuque: true)
        }
    }
}
