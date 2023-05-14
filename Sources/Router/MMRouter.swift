//
//  MMRouter.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
let kMMRouterDefaultTimeOut = 1000

public protocol MMRouterEventProtocol {
    static var key: String { get }
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

//    MARK: Public
    
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
    
    
//    MARK: Register
    /// 注册 基本方法
    ///
    /// - Parameter model:
    public func register(model: MMRouterModel) {
        setRegisterValue(model: model)
    }

    /// 注册 无回调
    ///
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block:  实现block
    public func register(key: String, block: @escaping () ->Void) {
        let model = MMRouterModel(target: self, key: key) { (_, _) in
            block()
        }
        register(model: model)
    }

    /// 注册 带参数
    ///
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block: 实现block,带参数传递
    public func register(key: String, block: @escaping (_ params: Any?) ->Void) {
        let model = MMRouterModel(target: self, key: key) { (sender, _) in
            block(sender)
        }
        register(model: model)
    }

    /// 注册 带参数和回调block
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block: 实现block 带参数传递和完成回调block, 可在调用方发起block, 注册方接收block
    public func register(key: String, block: ((_ params: Any?, _ finishBlock: ((_ params: Any?) -> Void)?) ->Void)?) {
        register(model: MMRouterModel(target: self, key: key, handler: block))
    }
    
    /// 监听消息
    public func listen(eventClass: MMRouterEventProtocol.Type, block: ((_ params: Any?, _ finishBlock: ((_ params: Any?) -> Void)?) ->Void)?) {
        register(model: MMRouterModel(target: self, key: eventClass.key, handler: block))
    }
    
    //    MARK: CallMethod
    // push消息
    @discardableResult public func push(event: MMRouterEventProtocol) -> Bool {
        guard let modelList = getRegisterValue(key: type(of: event).key) else {
            return false
        }
        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                }
                block(event, nil)
            }
        }
        return true
    }

    /// 打开action
    ///
    /// - Parameters:
    ///   - key: key
    ///   - params: 传入参数
    ///   - finishBlock: 服务方的回调block
    /// - Returns: 是否正常调用接口
    @discardableResult public func call(key: String, params: Any? = nil, finishBlock: ((_ params: Any?) ->Void)? = nil) -> Bool {
        guard let modelList = getRegisterValue(key: key) else {
            return false
        }

        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                    //TODO: 只移除单个
//                    unregister(key: key) //target对象已销毁,不再监听该注册事件
                }
                block(params, finishBlock)
            }
        }
        return true
    }

    /// 使用url方式传参
    ///
    /// - Parameters:
    ///   - url: url 例: "http://userData?param1=这是参数1&param2=这是参数2" ,"http://userData"做为key值进行匹配, 符号"?"后面为参数,以Array形式保存
    ///   - finishBlock: 完成回调
    /// - Returns: 是否正常调用接口
    @discardableResult public func openURL(url: String, finishBlock: ((_ params: Any?) ->Void)? = nil) -> Bool {
        let list = url.mm_split("?")
        guard let key = list.first else {
            return false
        }
//        var params: String?
        var dic: [String: String] = [:]
        if list.count == 2, let last = list.last {
            let params = last.mm_split("&")
            for item in params {
                let keyValue = item.mm_split("=")
                if let key = keyValue.first, let value = keyValue.last {
                    dic[key] = value
                }
            }
        } else if list.count > 2 {
            print("[MMRouter] url格式错误,不能有多个'?'")

            return false
        }
        guard let modelList = getRegisterValue(key: key) else {
            return false
        }
        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                    //TODO: 只移除单个
//                    unregister(key: key) //target对象已销毁,不再监听该注册事件
                }
                block(dic, finishBlock)
            }
        }
        
        return true
    }
}

