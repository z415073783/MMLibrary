//
//  MMRouter.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
let kMMRouterDefaultTimeOut = 1000

public protocol MMRouterDataProtocol {
}

extension MMRouterDataProtocol {
    static var zlm_key: String {
        return NSStringFromClass(self as! AnyClass)
    }
}

public class MMRouterManager {
    static let share = MMRouterManager()
    var router: MMRouter = MMRouter()
}

@objc public class MMRouter: NSObject {
    
    private var registerMap: [String: [MMRouterModel]] = [:]
    let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.maxConcurrentOperationCount = 1
        _queue.name = "MMRouterQueue"
        return _queue
    }()

    private func setRegisterValue(model: MMRouterModel) {
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            
            if var list = self.registerMap[model.key] {
                list.append(model)
                self.registerMap[model.key] = list
            } else {
                self.registerMap[model.key] = [model]
            }
            semaphore.signal()
        }
        let result = semaphore.mm_wait(kMMRouterDefaultTimeOut)
        if result == .timedOut {
            print("设置连接超时 model = \(model)")
        }
    }
    private func getRegisterValue(key: String) ->[MMRouterModel]? {
        let semaphore = DispatchSemaphore(value: 0)
        var modelList: [MMRouterModel]?
        queue.addOperation { [weak self] in
            modelList = self?.registerMap[key]
            semaphore.signal()
        }
        let result = semaphore.mm_wait(kMMRouterDefaultTimeOut)
        if result == .timedOut {
            print("获取连接超时 key = \(key)")
        }
        return modelList
    }

    
//    MARK: Register
    /// 注册 基本方法
    ///
    /// - Parameter model:
    private func register(model: MMRouterModel) {
        setRegisterValue(model: model)
    }
    
//    MARK: Unregister
    //移除指定target的单个注册事件
    public func unregister(key: String, finishBlock: (() ->Void)? = nil) {
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation { [weak self] in
            
            let targetAddress = self?.mm_getAddressIdentifity()
            if var modelList = self?.registerMap[key] {
                var isChange = false
                for i in (0 ..< modelList.count).reversed() {
                    let model = modelList[i]
                    if model.target?.mm_getAddressIdentifity() == targetAddress {
                        modelList.remove(at: i)
                        isChange = true
                    }
                }
                if isChange {
                    if modelList.count == 0 {
                        self?.registerMap[key] = nil
                    } else {
                        self?.registerMap[key] = modelList
                    }
                }
            }
            
            semaphore.signal()
        }
        
        let result = semaphore.mm_wait(kMMRouterDefaultTimeOut)
        if result == .timedOut {
            print("获取连接超时 key = \(key)")
        }
        if let block = finishBlock {
            block()
        }
    }

    public func unregister(routerModel: MMRouterModel, finishBlock: (() ->Void)? = nil) {
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation { [weak self] in
            
            let targetAddress = self?.mm_getAddressIdentifity()
            if var modelList = self?.registerMap[routerModel.key] {
                var isChange = false
                
                for i in (0 ..< modelList.count).reversed() {
                    let model = modelList[i]
                    if model == routerModel {
                        modelList.remove(at: i)
                        isChange = true
                        break
                    }
                }
                if isChange {
                    if modelList.count == 0 {
                        self?.registerMap[routerModel.key] = nil
                    } else {
                        self?.registerMap[routerModel.key] = modelList
                    }
                }
            }
            
            semaphore.signal()
        }
        
        let result = semaphore.mm_wait(kMMRouterDefaultTimeOut)
        if result == .timedOut {
            print("获取连接超时 key = \(routerModel.key)")
        }
        if let block = finishBlock {
            block()
        }
    }
    
    /// 移除指定target的所有注册数据
    ///
    /// - Parameters:
    ///   - target: target
    ///   - finishBlock:
    public func unregister(finishBlock: (() ->Void)? = nil) {
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation { [weak self] in
            let targetAddress = self?.mm_getAddressIdentifity()
            for (key, modelList) in self?.registerMap ?? [:] {
                var mutiModelList = modelList
                var isChange = false
                for i in (0 ..< modelList.count).reversed() {
                    let model = modelList[i]
                    if model.target?.mm_getAddressIdentifity() == targetAddress {
                        mutiModelList.remove(at: i)
                        isChange = true
                    }
                }
                if isChange {
                    if mutiModelList.count == 0 {
                        self?.registerMap[key] = nil
                    } else {
                        self?.registerMap[key] = mutiModelList
                    }
                }
            }
            semaphore.signal()
        }
        let result = semaphore.mm_wait(kMMRouterDefaultTimeOut)
         if result == .timedOut {
             print("获取连接超时")
         }
        if let block = finishBlock {
           block()
       }
    }
    
    /// 监听消息
    @discardableResult public func listen(eventClass: MMRouterDataProtocol.Type, block: ((_ value: MMRouterDataProtocol?) ->Void)?) -> MMRouterModel {
        let model = MMRouterModel(target: self, key: eventClass.zlm_key, handler: block)
        register(model: model)
        return model
    }

    // push消息
    @discardableResult public func push(event: MMRouterDataProtocol) -> Bool {
        if !Thread.isMainThread {
            MMLOG.debug("")
        }
        MMLOG.info("[MMRouter] push event: \(type(of: event).zlm_key)")
        guard let modelList = getRegisterValue(key: type(of: event).zlm_key) else {
            return false
        }
        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                }
                block(event)
            }
        }
        return true
    }
}

