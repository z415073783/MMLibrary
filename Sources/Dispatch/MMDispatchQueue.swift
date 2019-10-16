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
    

    //    private let _dispatchQueue = getOperationQueue(withName: "YLBasicDispatchQueue", maxCount: 1)
    public class func getOperationQueue(withName name: String, maxCount: Int, finishBlock: @escaping (_ queue: MMOperationQueue) -> Void) {
        mm_executeOnMainThread {
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
    /// - Returns: OperationQueue实例
    public class func getOperationQueue(withName name: String, maxCount: Int, isFreeQuque: Bool = false) -> MMOperationQueue {
        //        _ = MMBasicDispatchManager.shared.semaphore.wait()
        if let queue = shared.allOperationQueueDictionary[name] {
            //            shared.semaphore.signal()
            return queue
        }
        else {
            //            if Thread.isMainThread == false {
            //                MMLOG.info("getOperationQueue方法必须放在主线程中! name = \(name)")
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
    //                for (key, value) in MMBasicDispatchManager.shared.allOperationQueueDictionary {
    //                    if value.operationCount == 0 {
    //                        MMBasicDispatchManager.shared.allOperationQueueDictionary[key] = nil
    //                    }
    //                }
    //            }
    //        })
    //    }
    
    
    /// 移除指定名字的OperationQueue
    ///
    /// - Parameter name: queue的名字
    public class func removeFreeOperationQueue(name: String) {
        mm_executeOnMainThread {
            if shared.allOperationQueueDictionary[name] != nil {
                shared.allOperationQueueDictionary[name] = nil
            }
        }
    }
    
    
    /// 移除所有队列中的任务
    public class func removeAllOperations() {
        mm_executeOnMainThread {
            for (_, queue) in shared.allOperationQueueDictionary.values.enumerated() {
                queue.cancelAllOperations()
            }
        }
        
    }
    
    /// 移除即时队列
    public class func removeFreeOperations() {
        mm_executeOnMainThread {
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
