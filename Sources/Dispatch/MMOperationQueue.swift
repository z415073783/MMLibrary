//
//  MMOperationQueue.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

/// MMOperationQueue实例的配置类
public class MMOperationQueueConfig: NSObject {
    
    /// 单例
    public static let shared = MMOperationQueueConfig()
    
    /// 是否设置调整所有任务优先级
    public var isNeedModifyAllOperationPriority: Bool {
        set {
            atomicIsNeedModifyAllOperationPriority.set(newValue)
        }
        get {
            return atomicIsNeedModifyAllOperationPriority.get() ?? false
        }
    }
    private var atomicIsNeedModifyAllOperationPriority: MMAtomicVar<Bool> = MMAtomicVar(false)
    
    /// 预设优先级等级
    public var modifiedQueuePriority: Operation.QueuePriority {
        set {
            atomicModifiedQueuePriority.set(newValue)
        }
        get {
            return atomicModifiedQueuePriority.get() ?? .veryLow
        }
    }
    private var atomicModifiedQueuePriority: MMAtomicVar<Operation.QueuePriority> = MMAtomicVar(.veryLow)
    
    /// 预设优先级服务
    public var modifiedQualityOfService: QualityOfService {
        set {
            atomicModifiedQualityOfService.set(newValue)
        }
        get {
            return atomicModifiedQualityOfService.get() ?? .background
        }
    }
    private var atomicModifiedQualityOfService: MMAtomicVar<QualityOfService> = MMAtomicVar(.background)
}

/// OperationQueue子类
public class MMOperationQueue: OperationQueue {
    
    /// 是否是即时队列
    public var isFreeQueue: Bool = false
    
    /// 是否支持在MMOperationQueueConfig设置调整任务优先级时作用
    public var isSupportModifedPriority = true
    
    /// 构造方法
    ///
    /// - Parameter maxCount: 最大并发数，默认为1
    public init(maxCount: Int = 1) {
        super.init()
        self.maxConcurrentOperationCount = maxCount
    }
    
    /// 执行线程
    ///
    /// - Parameter block: 操作block
    public override func addOperation(_ block: @escaping () -> Void) {
        let op = BlockOperation(block: block)
        if isSupportModifedPriority && MMOperationQueueConfig.shared.isNeedModifyAllOperationPriority {
            op.queuePriority = MMOperationQueueConfig.shared.modifiedQueuePriority
            op.qualityOfService = MMOperationQueueConfig.shared.modifiedQualityOfService
        }
        
        addOperation(op)
    }
    
    /// 执行线程操作
    ///
    /// - Parameter op: Operation
    public override func addOperation(_ op: Operation) {
        if isSupportModifedPriority && MMOperationQueueConfig.shared.isNeedModifyAllOperationPriority {
            op.queuePriority = MMOperationQueueConfig.shared.modifiedQueuePriority
            op.qualityOfService = MMOperationQueueConfig.shared.modifiedQualityOfService
        }
        
        super.addOperation(op)
    }
    
    
    /// 执行一组线程操作
    ///
    /// - Parameters:
    ///   - ops: [Operation]
    ///   - wait: waitUntilFinished
    public override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        if isSupportModifedPriority && MMOperationQueueConfig.shared.isNeedModifyAllOperationPriority {
            for (_, op) in ops.enumerated() {
                op.queuePriority = MMOperationQueueConfig.shared.modifiedQueuePriority
                op.qualityOfService = MMOperationQueueConfig.shared.modifiedQualityOfService
            }
        }
        
        super.addOperations(ops, waitUntilFinished: wait)
    }
    
}
