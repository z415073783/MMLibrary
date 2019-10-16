//
//  MMSqliteOperation.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
import SQLite3
//#define SQL_primaryKey @"primary key"   //主键
//#define SQL_autoincrement @"autoincrement"   //自动增量
//#define SQL_unique @"unique"   //唯一
//#define SQL_integer @"integer"   //int类型  无法使用
//#define SQL_text @"text"   //text类型
public let SQL_primarykey = "PRIMARY KEY"
public let SQL_autoincrement = "AUTOINCREMENT"
public let SQL_unique = "UNIQUE"
public let SQL_integer = "INTEGER"
public let SQL_text = "TEXT"
public let SQL_float = "FLOAT"

public class MMSqliteOperation: NSObject {
    //    var _sqlite:sqlite3_vfs? = nil
    var db: OpaquePointer?
    
    /**
     打开数据库
     
     - parameter dbName: 数据库名
     
     - returns: 是否成功
     */
    public func openSqlite(_ dbName: String) -> Bool {
        //获取根路径
        let doc = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        guard let docPath = doc.first else {
            MMLOG.error("开启数据库失败,无法获取根路径")
            return false
        }
        
        //拼接完整数据库路径
        let path = docPath + "/" + dbName
        //        MMLOG.debug("sqlite path:\(path)")
        if sqlite3_open(path, &db) == SQLITE_OK {
            //            MMLOG.debug("开启数据库成功:path:\(path)")
            return true
        } else {
            MMLOG.error("开启数据库失败,数据库路径:\(path)")
            closeSQLite()
            return false
        }
    }
    
    //根据路径获取打开数据库
    public func openSqliteWithPath(_ dbPath: String) -> Bool {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            //            MMLOG.debug("开启数据库成功:path:\(path)")
            return true
        }else{
            MMLOG.error("开启数据库失败,数据库路径:\(dbPath)")
            closeSQLite()
            return false
        }
    }
    
    /**
     创建表
     
     - parameter tableName: 表名
     - parameter params: 参数字典 [参数1:[属性1,属性2,...],参数2:[属性1,属性2,...],...]
     - returns: 是否成功
     */
    public func createTable(_ tableName: String, Parameters params: Dictionary<String, Array<String>>) -> Bool {
        let newParams = splitParams(params)
        
        if db == nil {
            MMLOG.error("数据库实例不存在")
            return false
        }
        let sql = "CREATE TABLE IF NOT EXISTS " + tableName + " (" + newParams + ")"
        var stmt: OpaquePointer? = nil
        //        MMLOG.debug(sql)
        let sqlReturn = sqlite3_prepare_v2(db, sql.cString(using: String.Encoding.utf8)!, -1, &stmt, nil)
        if sqlReturn != SQLITE_OK {
            MMLOG.error("sqlite操作:\(tableName)创建失败")
            return false
        }
        //执行sql
        let success = sqlite3_step(stmt)
        //释放stms
        sqlite3_finalize(stmt)
        if success != SQLITE_DONE {
            MMLOG.error("sqlite操作:执行语句失败")
            return false
        }
        return true
    }
    /**
     创建表
     
     - parameter sql: sql语句
     
     - returns: 是否成功
     */
    public func createTable(_ sql: String) -> Bool {
        if db == nil {
            MMLOG.error("数据库实例不存在")
            return false
        }
        var stmt: OpaquePointer? = nil
        //sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
        //第一个参数跟前面一样，是个sqlite3 * 类型变量，
        //第二个参数是一个 sql 语句。
        //第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
        //第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
        //第五个参数是错误信息提示，一般不用,为nil就可以了。
        //如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
        let sqlReturn = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if sqlReturn != SQLITE_OK {
            MMLOG.error("数据语句解析失败:\(sql)")
            return false
        }
        
        //执行sql
        let success = sqlite3_step(stmt)
        //释放stms
        sqlite3_finalize(stmt)
        if success != SQLITE_DONE {
            MMLOG.error("数据库操作失败")
            return false
        }
        return true
    }
    /**
     执行没有返回值的数据库语句
     
     - parameter sql: 数据库语句
     
     - returns: 是否成功
     */
    public func execSQL(_ sql: String) -> Bool {
        if db == nil {
            MMLOG.error("数据库未初始化")
            return false
        }
        /**
         1. 数据库指针
         2. SQL 字符串的 C 语言格式
         3. 回调，执行完成 SQL 指令之后的函数回调，通常都是 nil
         4. 回调的第一个参数的指针
         5. 错误信息，通常也传入 nil
         */
        return sqlite3_exec(db, sql.cString(using: String.Encoding.utf8)!, nil, nil, nil) == SQLITE_OK
    }
    /**
     执行sql返回一个结果集(对象数组)
     
     - parameter sql: sql语句
     */
    public func recordSet(_ sql: String) -> NSMutableArray {
        
        let allData: NSMutableArray = NSMutableArray()
        if db == nil {
            MMLOG.error("数据库未初始化")
            return allData
        }
        
        var stmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sql.cString(using: String.Encoding.utf8)!, -1, &stmt, nil) == SQLITE_OK {
            if let stmt = stmt {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    allData.add(recordData(stmt))
                }
            }
        }
        
        if let stmt = stmt {
            sqlite3_finalize(stmt)
        }
        return allData
    }
    /**
     关闭数据库
     */
    public func closeSQLite() {
        if db != nil {
            sqlite3_close(db)
            db = nil
        }
    }
    
    fileprivate func recordData(_ stmt: OpaquePointer) -> NSMutableDictionary {
        let onceData: NSMutableDictionary = NSMutableDictionary()
        let count = sqlite3_column_count(stmt)
        for i in 0..<count {
            if let col_name = sqlite3_column_name(stmt, i),
                let name = String(validatingUTF8: col_name) {
                let type = sqlite3_column_type(stmt, i)
                //根据字段类型,提取对应列的值
                switch type {
                case SQLITE_INTEGER:
                    
                    let value = NSNumber(value: sqlite3_column_int64(stmt, i) as Int64)
                    onceData.setObject(value, forKey: name as NSCopying)
                case SQLITE_FLOAT:
                    
                    let value = NSNumber(value: sqlite3_column_double(stmt, i) as Double)
                    onceData.setObject(value, forKey: name as NSCopying)
                case SQLITE_NULL:
                    
                    onceData.setObject(NSNull(), forKey: name as NSCopying)
                case SQLITE_TEXT:
                    guard let chars = sqlite3_column_text(stmt, i) else {
                        return onceData
                    }
                    //                    MMLOG.debug("chars = \(chars)")
                    //                    :UnsafePointer<CChar>
                    //                    let chars = UnsafePointer(sqlite3_column_text(stmt, i))
                    let str: String = String(cString: chars)
                    onceData.setObject(str, forKey: name as NSCopying)
                case let type:
                    MMLOG.error("数据库不支持该类型:\(type)")
                }
            }
        }
        return onceData
    }
    
    //拆分数据
    func splitParams(_ sender: Dictionary<String, Array<String>>) -> String {
        var result: String = ""
        var i: Int = 0
        for (key, value) in sender {
            var once: String = key
            for item in value {
                once = once+" "+item
            }
            
            result+=once
            
            if sender.count > (i+1) {
                result+=","
            }
            i+=1
        }
        return result
    }
    
}
