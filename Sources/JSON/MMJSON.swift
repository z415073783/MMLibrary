//
//  MMJSON.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

/*
 使用范例:
 声明model: 申明方式和HandyJSON一致,但是继承的类要改为MMJSONCodable
 // MARK: - 👉 获取自己的ID
 class UserDataMyIDModel: NSObject {
 // 获取自己的ID
 static let interfaceName = "getMyId"
 
 struct Input: MMJSONCodable {
 }
 
 struct Output: MMJSONCodable {
 var id: String = ""
 }
 }
 
 调用方式: 需要传入name,inputmodel和 outputmodel.self, 统一使用MMJSON调用
 MMJSON.getDataOnce(name: UserDataMyIDModel.interfaceName, input: UserDataMyIDModel.Input(), bodyClass: UserDataMyIDModel.Output.self) { (output, result) in
 }
 
 
 
 
 
 */





import Foundation
public typealias MMJSONCodable = Codable
public typealias MMJSONEncodable = Encodable
public enum MMJSONResultType: String, MMJSONCodable {
    case fail = "resultType::FAIL",
    success = "resultType::SUCCESS"
}

public struct MMJSONResult: MMJSONCodable {
    public var errorCode: Int = 0
    public var errorDesc: String = ""
    public var operateID: String = ""
    public var type: MMJSONResultType = .fail
    public init() {
    }
}
struct MMJSONBaseOutputModel<T: MMJSONCodable>: MMJSONCodable {
    var result: MMJSONResult?
    var body: T?
}
struct MMJSONBaseModel<T: Codable>: MMJSONCodable {
    var method: String = ""
    var param: T?
}

extension MMDispatchQueue {
    //    rpc专用
    public class var MMJSONOperatorQueue: MMOperationQueue {
        get {
            return getOperationQueue(withName: #function, maxCount: 100)
        }
    }
}
@objc public class MMJSONRpcManager: NSObject {
    @objc public static let shared = MMJSONRpcManager()
    
    @objc public var call: ((_ info: String?) -> String)?
    //配置数据源
    @objc public class func setCall(block: ((_ info: String?) -> String)?) {
        shared.call = block
    }
}

public class MMJSON {
    
    /// 队列执行,只保留头尾任务, 移除重复队列
    ///
    /// - Parameters:
    ///   - name: rpc接口名
    ///   - input: 传入model
    ///   - bodyClass: 传出body model
    ///   - block: 返回代码块
    /// - Returns: 运行队列
    @discardableResult
    public class func getDataOnce <R: MMJSONCodable, T: MMJSONCodable> (name: String, input: R?, bodyClass: T.Type,
                                                                        block: @escaping (_ model: T?, _ result: MMJSONResult?) -> Void) -> BlockOperation {
        let queue = MMDispatchQueue.getOperationQueue(withName: name, maxCount: 1)
        let operations = queue.operations
        for operation in operations {
            if operation.isExecuting == false {
                operation.cancel()
            }
        }
        let newOperation = BlockOperation()
        newOperation.addExecutionBlock { [weak newOperation] in
            guard let newOperation = newOperation else { return }
            guard !newOperation.isCancelled else { return }
            getDataSync(name: name, input: input, bodyClass: bodyClass, block: { (body, result) in
                guard !newOperation.isCancelled else { return }
                mm_executeOnMainThread {
                    block(body, result)
                }
            })
        }
        queue.addOperation(newOperation)
        return newOperation
    }
    
    
    /// 多线程执行 常用方法
    ///
    /// - Parameters:
    ///   - name: rpc接口名
    ///   - input: 传入model
    ///   - bodyClass: 传出body model
    ///   - isAsync: 是否异步调用
    ///   - block: 返回代码块
    /// - Returns: 运行队列
    @discardableResult
    public class func getData<R: MMJSONCodable, T: MMJSONCodable> (name: String, input: R?, bodyClass: T.Type, isAsync: Bool = true,
                                                                   block: @escaping (_ model: T?, _ result: MMJSONResult?) -> Void) -> BlockOperation? {
        if isAsync {
            let newOperation = BlockOperation()
            newOperation.addExecutionBlock {
                getDataSync(name: name, input: input, bodyClass: bodyClass, block: { (body, result) in
                    mm_executeOnMainThread {
                        block(body, result)
                    }
                })
            }
            
            let operationQueue = MMDispatchQueue.MMJSONOperatorQueue
            operationQueue.addOperation(newOperation)
            return newOperation
        } else {
            getDataSync(name: name, input: input, bodyClass: bodyClass, block: { (body, result) in
                block(body, result)
            })
            return nil
        }
    }
    
    //接口可选同步Or异步
    
    
    
    
    /// 单线程队列执行
    ///
    /// - Parameters:
    ///   - name: rpc接口名
    ///   - input: 传入model
    ///   - bodyClass: 传出body model
    ///   - block: 返回代码块
    /// - Returns: 运行队列
    @discardableResult
    public class func getDataQueue <R: MMJSONCodable, T: MMJSONCodable> (name: String, input: R?, bodyClass: T.Type,
                                                                         block: @escaping (_ model: T?, _ result: MMJSONResult?) -> Void) -> BlockOperation {
        let queue = MMDispatchQueue.getOperationQueue(withName: name, maxCount: 1)
        let newOperation = BlockOperation()
        newOperation.addExecutionBlock {
            getDataSync(name: name, input: input, bodyClass: bodyClass, block: { (body, result) in
                mm_executeOnMainThread {
                    block(body, result)
                }
            })
        }
        queue.addOperation(newOperation)
        return newOperation
    }
    
    public class func getDataQueueNotMainReturn <R: MMJSONCodable, T: MMJSONCodable> (name: String, input: R?, bodyClass: T.Type,
                                                                                      block: @escaping (_ model: T?, _ result: MMJSONResult?) -> Void) -> BlockOperation {
        let queue = MMDispatchQueue.getOperationQueue(withName: name, maxCount: 1)
        let newOperation = BlockOperation()
        newOperation.addExecutionBlock {
            getDataSync(name: name, input: input, bodyClass: bodyClass, block: { (body, result) in
                block(body, result)
            })
        }
        queue.addOperation(newOperation)
        return newOperation
    }
    
    /// 基础方法
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - input: <#input description#>
    ///   - bodyClass: <#bodyClass description#>
    ///   - block: <#block description#>
    public class func getDataSync <R: MMJSONCodable, T: MMJSONCodable> (name: String, input: R?, bodyClass: T.Type,
                                                                        block: @escaping (_ model: T?, _ result: MMJSONResult?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let inputData = try encoder.encode(MMJSONBaseModel(method: name, param: input))
            let inputStr = String(data: inputData, encoding: String.Encoding.utf8)
            
            guard let rpcBlock = MMJSONRpcManager.shared.call else {
                MMLOG.error("未设置Rpc数据获取方法")
                return
            }

            if MMLibraryConfig.shared.isDebug {
                MMLOG.debug("DEBUG rpc Data: Input = \(String(describing: inputStr))")
            }
            
            let result = rpcBlock(inputStr)
            if MMLibraryConfig.shared.isDebug {
                MMLOG.debug("DEBUG rpc Data: Output = \(String(describing: result))")
            }
            let decoder = JSONDecoder()
            let output = try decoder.decode(MMJSONBaseOutputModel<T>.self, from: result.data(using: String.Encoding.utf8)!)
            
            if let outputResult = output.result {
                block(output.body, outputResult)
                if outputResult.type == .fail {
                    MMLOG.error("RPC接口请求失败! outputResult = \(outputResult) \n inputStr = \(String(describing: inputStr))")
                }
            } else {
                var result = MMJSONResult()
                result.type = .success
                block(output.body, result)
            }
        } catch {
            let err = """
            name = \(name)
            ======================================================================
            json数据解析失败,请检查以下原因:
            1.参数类型是否一致?
            2.是否有缺少参数?
            3.是否有多的参数? 如果有多的参数但是并不是Rpc需要的参数,请改为可选类型(?)
            ======================================================================
            """
            print("error = \(error) \n\(err)")
            assert(false, "error = \(error)")
            block(nil, MMJSONResult())
        }
    }
}

public extension String {
    /// 字符串转model
    ///
    /// - Parameter DataClass: model对象
    /// - Returns: 返回实例
    func getJSONDataSync<T: MMJSONCodable> (_ DataClass: T.Type) ->T? {
        do {
            let decoder = JSONDecoder()
            let output = try decoder.decode(DataClass, from: self.data(using: String.Encoding.utf8) ?? Data())
            return output
        } catch {
            print("字符串转换错误: OutputClass = \(DataClass)\n value = \(self)")
            return nil
        }
    }
    
}

public extension NSDictionary {
    /// json转model
    ///
    /// - Parameter DataClass: model对象
    /// - Returns: 返回实例
    func getJSONModelSync<T: MMJSONCodable> (_ DataClass: T.Type) ->T? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.fragmentsAllowed)
            let decoder = JSONDecoder()
            let output = try decoder.decode(DataClass, from: data)
            return output
        } catch {
            print("字符串转换错误: OutputClass = \(DataClass)\n value = \(self) error = \(error)")
            return nil
        }
    }
}
public extension NSArray {
    /// json转model
    ///
    /// - Parameter DataClass: model对象
    /// - Returns: 返回实例
    func getJSONModelSync<T: MMJSONCodable> (_ DataClass: T.Type) ->T? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.fragmentsAllowed)
            let decoder = JSONDecoder()
            let output = try decoder.decode(DataClass, from: data)
            return output
        } catch {
            print("字符串转换错误: OutputClass = \(DataClass)\n value = \(self) error = \(error)")
            return nil
        }
    }
}
public extension Data {
    func getJSONModelSync<T: MMJSONCodable>(_ DataClass: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            let output = try decoder.decode(DataClass, from: self)
            return output
        } catch {
            print("数据转换错误: OutputClass = \(DataClass)\n value = \(self) error = \(error)")
            return nil
        }
    }
}

public extension MMJSONEncodable {
    func getJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// 转dictionary or array
    /// - Returns:dictionary or array
    func getJSONObject() -> Any? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}

