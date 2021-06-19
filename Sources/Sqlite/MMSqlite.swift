//
//  MMSqlite.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
// 多线程sqlite调用接口层

import Foundation

public class MMSqlite: NSObject {
    static public let shared: MMSqlite = MMSqlite()
    var queue: OperationQueue?
    //默认未开启多线程
    var isQueue: Bool {
        get {
            return (queue != nil) ? true : false
        }
        set {
            if newValue {
                queue = MMDispatchQueue.getOperationQueue(withName: self.description, maxCount: 1)
            } else {
                queue = nil
            }
        }
    }
    
    //处理队列
    //    var isolationQueue: DispatchQueue = DispatchQueue(label: "isolationQueue", attributes: [])
    //返回结果队列 直接返回原线程
//    var returnQueue: DispatchQueue = DispatchQueue(label: "returnQueue", attributes: [])
    
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
    public func openSql(_ dbName: String, queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) -> Void) {
        
        guard let queue = queue ?? self.queue else {
            let isResult: Bool = self.operation.openSqlite(dbName)
            if isResult == false {
                print("sqlite创建表失败")
            }
            block(isResult)
            return
        }
        let current = OperationQueue.current
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.openSqlite(dbName)
            current?.addOperation({
                block(isResult)
            })
        }
    }
    
    //打开数据库 指定路径
    public func openSqlWithPath(_ dbPath: URL, queue: OperationQueue? = nil, block:@escaping (_ isSuccess:Bool)->Void) -> Void {
        guard let queue = queue ?? self.queue else {
            let isResult:Bool = self.operation.openSqliteWithPath(dbPath)
            MMLOG.info("打开数据库: \(dbPath), \(isResult)")
            block(isResult)
            return
        }
        
        let current = OperationQueue.current
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            
            let isResult:Bool = self.operation.openSqliteWithPath(dbPath)
            current?.addOperation({
                MMLOG.info("打开数据库: \(dbPath), \(isResult)")
                block(isResult)
            })
        }
    }
    
    public func closeSql(isSafe: Bool = true) {
        if isSafe {
            queue?.waitUntilAllOperationsAreFinished()
        }
        operation.closeSQLite()
    }
    //移除所有任务
    public func removeAllTasks(queue: OperationQueue? = nil) {
        guard let queue = queue ?? self.queue else {
            MMLOG.info("当前未开启MMSqlite多线程")
            return
        }
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
    }
    
    /**
     创建表
     
     - parameter sqlName: 表名称
     - parameter parames: 参数字典 [参数1:[属性1,属性2,...],参数2:[属性1,属性2,...],...]
     - parameter block:   是否成功
     */
    public func createTable(_ sqlName: String, parames: [MMSqliteOperationCreateProperty], queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) -> Void) {
        
        guard let queue = queue ?? self.queue else {
            let isResult: Bool = self.operation.createTable(sqlName, Parameters: parames)
            if isResult == false {
                print("sqlite创建表失败")
            }
            block(isResult)
            return
        }
        let currentQueue = OperationQueue.current
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.createTable(sqlName, Parameters: parames)
            currentQueue?.addOperation({
                block(isResult)
            })
        }
    }
//    deleteTable
    public func deleteTable(_ sqlName: String, queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) -> Void) {
        guard let queue = queue ?? self.queue else {
            let isResult: Bool = self.operation.deleteTable(sqlName)
            if isResult == false {
                print("sqlite创建表失败")
            }
            block(isResult)
            return
        }
        let currentQueue = OperationQueue.current
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.deleteTable(sqlName)
            currentQueue?.addOperation({
                block(isResult)
            })
        }
    }
    
    /**
     //执行没有返回值的数据库语句
     
     - parameter sql:   sql语句
     - parameter block: 返回成功or失败
     */
    public func update(_ sql: String, queue: OperationQueue? = nil, block:@escaping ((_ isSuccess: Bool) -> Void)) {
        guard let queue = queue ?? self.queue else {
            let isResult: Bool = self.operation.execSQL(sql)
            if isResult == false {
                MMLOG.debug("sqlite操作失败: sql = \(sql)")
                
            }
            block(isResult)
            return
        }
        let currentQueue = OperationQueue.current
        //        queue.waitUntilAllOperationsAreFinished()
        //        queue.maxConcurrentOperationCount = 1
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: Bool = self.operation.execSQL(sql)
            if isResult == false {
                MMLOG.debug("sqlite操作失败: sql = \(sql)")
//                print("sqlite操作失败")

            }
            currentQueue?.addOperation({
                block(isResult)
            })
        }
    }
    /**
     执行sql返回一个结果集(对象数组)
     
     - parameter sql:   sql语句
     - parameter block: 返回对象数组
     */
    public func select(_ sql: String, queue: OperationQueue? = nil, block:@escaping ((_ result: NSMutableArray) -> Void)) {
        
        guard let queue = queue ?? self.queue else {
            let isResult: NSMutableArray = self.operation.recordSet(sql)
            block(isResult)
            return
        }
        let currentQueue = OperationQueue.current
        //        queue.waitUntilAllOperationsAreFinished()
        //        queue.maxConcurrentOperationCount = 1
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let isResult: NSMutableArray = self.operation.recordSet(sql)
            currentQueue?.addOperation({
                block(isResult)
            })
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
