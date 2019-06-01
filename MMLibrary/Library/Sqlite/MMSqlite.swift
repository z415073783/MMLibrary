//
//  MMSqlite.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
public let mm_kSqlQueueName = "mm_MySqlQueueName"
public class MMSqlite: NSObject {
    
    static public let shared: MMSqlite = MMSqlite()
    
    let queue = MMDispatchQueue.getOperationQueue(withName: mm_kSqlQueueName, maxCount: 1)
    //处理队列
    //    var isolationQueue: DispatchQueue = DispatchQueue(label: "isolationQueue", attributes: [])
    //返回结果队列
    var returnQueue: DispatchQueue = DispatchQueue(label: "returnQueue", attributes: [])
    
    //数据库操作对象(每个数据库一个对象,默认只有一个数据库) 要创建多个数据库请使用init方法
    public var operation: MMSqliteOperation = MMSqliteOperation()
    
    override public init() {
        super.init()
    }
    /**
     打开数据库
     
     - parameter dbName: 数据库名称
     - parameter block:  是否成功
     */
    public func openSql(_ dbName: String, block:@escaping (_ isSuccess: Bool) -> Void) {
        let blockOpera = BlockOperation()
        blockOpera.addExecutionBlock { [weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.openSqlite(dbName)
            self.returnQueue.async {
                block(isResult)
            }
        }
        queue.addOperation(blockOpera)
        
    }
    
    //打开数据库 指定路径
    public func openSqlWithPath(_ dbPath: String, block:@escaping (_ isSuccess:Bool)->Void) -> Void {
        let blockOpera = BlockOperation()
        blockOpera.addExecutionBlock { [weak self] in
            guard let `self` = self else { return }
            let isResult:Bool = self.operation.openSqliteWithPath(dbPath)
            self.returnQueue.async {
                block(isResult)
            }
        }
        queue.addOperation(blockOpera)
    }
    
    public func closeSql() {
        operation.closeSQLite()
    }
    //移除所有任务
    public func removeAllTasks(queueName: String = mm_kSqlQueueName) {
        let queue = MMDispatchQueue.getOperationQueue(withName: queueName, maxCount: 1)
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
    }
    
    /**
     创建表
     
     - parameter sqlName: 表名称
     - parameter parames: 参数字典 [参数1:[属性1,属性2,...],参数2:[属性1,属性2,...],...]
     - parameter block:   是否成功
     */
    public func createTable(_ sqlName: String, parames: Dictionary<String, Array<String>>, block:@escaping (_ isSuccess: Bool) -> Void) {
        let blockOpera = BlockOperation()
        blockOpera.addExecutionBlock {[weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.createTable(sqlName, Parameters: parames)
            self.returnQueue.async {
                block(isResult)
            }
        }
        queue.addOperation(blockOpera)
    }
    
    /**
     //执行没有返回值的数据库语句
     
     - parameter sql:   sql语句
     - parameter block: 返回成功or失败
     */
    public func update(_ sql: String,_ queueName: String? = mm_kSqlQueueName, block:@escaping ((_ isSuccess: Bool) -> Void)) {
        guard let queueName = queueName else {
            let isResult: Bool = self.operation.execSQL(sql)
            if isResult == false {
                print("sqlite操作失败: sql = \(sql)")
            }
            block(isResult)
            return
        }
        
        let queue = MMDispatchQueue.getOperationQueue(withName: queueName, maxCount: 1)
        //        queue.waitUntilAllOperationsAreFinished()
        //        queue.maxConcurrentOperationCount = 1
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.execSQL(sql)
            if isResult == false {
                print("sqlite操作失败: sql = \(sql)")
            }
            self.returnQueue.async {
                block(isResult)
            }
        }
    }
    /**
     执行sql返回一个结果集(对象数组)
     
     - parameter sql:   sql语句
     - parameter block: 返回对象数组
     */
    public func select(_ sql: String,_ queueName: String? = mm_kSqlQueueName, block:@escaping ((_ result: NSMutableArray) -> Void)) {
        guard let queueName = queueName else {
            let isResult: NSMutableArray = self.operation.recordSet(sql)
            block(isResult)
            return
        }
        let queue = MMDispatchQueue.getOperationQueue(withName: queueName, maxCount: 1)
        //        queue.waitUntilAllOperationsAreFinished()
        //        queue.maxConcurrentOperationCount = 1
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: NSMutableArray = self.operation.recordSet(sql)
            self.returnQueue.async {
                block(isResult)
            }
        }
        
    }
    /**
     拆分对象属性
     
     - parameter sender: 需要拆分的对象
     
     - returns: keys,values
     */
    public class func getObjectData(_ sender: NSObject) -> (keys: String, values: String) {
        let allKeys = sender.mm_getAllPropertys()
        var params: String = ""
        var paramValues: String = ""
        for i in 0...allKeys.count-1 {
            let key = allKeys[i]
            let number: NSNumber? = sender.mm_getValueOfProperty(key) as? NSNumber
            if number != nil {
                params+=key
                paramValues+=String(describing: number)
                if i < allKeys.count-1 {
                    params+=","
                    paramValues+=","
                }
                
            } else {
                if let value = sender.mm_getValueOfProperty(key) as? String {
                    params+=key
                    paramValues+="'"+value+"'"
                    if i < allKeys.count-1 {
                        params+=","
                        paramValues+=","
                    }
                }
            }
        }
        return (params, paramValues)
    }
    
}
