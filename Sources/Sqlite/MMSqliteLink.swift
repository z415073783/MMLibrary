//
//  MMSqliteLint.swift
//  MMLibrary
//
//  Created by zlm on 2020/3/27.
//  Copyright © 2020 zlm. All rights reserved.
// 链式结构封装层

import Foundation


enum MMSqliteOperationType {
    case createTable, select, insert, delete, update
}

class MMSqliteOperationModel {
    
}



class MMSqliteOperationCreateModel: MMSqliteOperationModel {
    //保存索引属性列表
    fileprivate var propertys: [MMSqliteOperationCreateProperty] = []
}


class MMSqliteOperationSelectModel: MMSqliteOperationModel {
    //保存需要查询的数据名称
    fileprivate var names: [String] = []
    fileprivate var wheres: [String] = []
}
class MMSqliteOperationInsertModel: MMSqliteOperationModel {
    fileprivate var values: [String: Any] = [:]
}
class MMSqliteOperationUpdateModel: MMSqliteOperationModel {
    fileprivate var values: [String: Any] = [:]
    fileprivate var wheres: [String] = []
}
class MMSqliteOperationDeleteModel: MMSqliteOperationModel {
    fileprivate var wheres: [String] = []
}


public class MMSqliteMake: NSObject {
    lazy var _sqliteObj = MMSqlite()
    //是否开启多线程
    var isQueue: Bool {
        get {
            return _sqliteObj.isQueue
        }
        set {
            _sqliteObj.isQueue = newValue
        }
    }

    //表名
    fileprivate var tableName: String?
    
    typealias MMSqliteTableName = String
    typealias MMSqlitePropertyName = String
    
    
    //参数属性  [表名, [字段名, [字段类型列表]]]
    fileprivate var tableInfos: [(MMSqliteTableName, [(MMSqlitePropertyName, [MMSqliteOperationPropertyType])])] = []
    
    
//    weak fileprivate var link: MMSqliteLink?
    //保存操作队列
    fileprivate var operations: [(MMSqliteOperationType, MMSqliteOperationModel)] = []
 
    
    //设置表名
    public func tableName(name: String) -> MMSqliteMake {
//       let make = MMSqliteMake()
       self.tableName = name
       return self
    }
//    var executeLock = NSLock()
    //执行
    public func execute(queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool,_ result: NSMutableArray) ->Void) {

        guard let name = tableName else {
            block(false, [])
            return
        }
        
//        let _block = block
//        if queue {
//            executeLock.lock()
//        }
         
        
        
        while operations.count > 0 {
            let operation = operations.removeFirst()
            switch operation.0 {
            case .createTable:
                guard let model = operation.1 as? MMSqliteOperationCreateModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.createTable(name, parames: model.propertys, queue: queue, block: { (isOk) in
                    MMLOG.info("创建表: \(name), \(isOk)")
                    block(isOk, [])
                })
            case .select:
                guard let model = operation.1 as? MMSqliteOperationSelectModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.select(getSelectSql(model: model), queue: queue) { (resultList) in
                    block(true, resultList)
                }
            case .insert:
                guard let model = operation.1 as? MMSqliteOperationInsertModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.update(getInsertSql(model: model), queue: queue) { (isOk) in
                    block(isOk, [])
                }
            case .delete:
//                getDeleteSql
                guard let model = operation.1 as? MMSqliteOperationDeleteModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.update(getDeleteSql(model: model), queue: queue) { (isOk) in
                    block(isOk, [])
                }
            case .update:
               guard let model = operation.1 as? MMSqliteOperationUpdateModel else {
                   block(false, [])
                   return
               }
               _sqliteObj.update(getUpdateSql(model: model), queue: queue) { (isOk) in
                   block(isOk, [])
               }
            }
        }
      
//        executeLock.unlock()
    }

    //关闭数据库
    public func close(isSafe: Bool = true) {
        _sqliteObj.closeSql(isSafe: isSafe)
    }
    
}




public class MMSqliteLink: MMSqliteMake {
    //数据库名称
//    private var sqlName: String?
    
//    lazy var _make = MMSqliteMake()
    
    
    //打开数据库 数据库名称 路径
    public init(name: String, path: String = MMFileData.getDocumentsPath(), isQueue: Bool = false, block: @escaping ((_ isSuccess: Bool, _ link: MMSqliteLink?) -> Void)) {
        super.init()
        let fullPath = path + "/" + name
        MMLOG.debug("path/name = \(fullPath)")
        self._sqliteObj.isQueue = isQueue
        self._sqliteObj.openSqlWithPath(fullPath) { [weak self](isOk) in
//            self?._make.link = self
            block(isOk, self ?? nil)
        }
    }
    
}



fileprivate typealias __CreateTableMake = MMSqliteMake
extension __CreateTableMake {

    //创建表命令
    public var createTable: MMSqliteMake {
        operations.append((MMSqliteOperationType.createTable, MMSqliteOperationCreateModel()))
        return self
    }
    
    
//MARK:创建表 -> 设置属性
    //设置key属性
    public func property(name: String) -> MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            model.propertys.append(MMSqliteOperationCreateProperty(name: name, types: []))
        }
        return self
    }
    public var primarykey: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.primarykey)
            }
        }
        
        return self
    }
    //设置自增属性需要遵循右侧顺序,否则会失败 -> integer.primarykey.autoincrement
    public var autoincrement: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.autoincrement)
            }
        }
        
        return self
    }
    public var unique: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.unique)
            }
        }
        
        return self
    }
    public var integer: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.integer)
            }
        }
        return self
    }
    public var text: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.text)
            }
        }
        return self
    }
    public var float: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.float)
            }
        }
        return self
    }
        
}


fileprivate typealias __CommonMake = MMSqliteMake
extension __CommonMake {
    
    /// set数据 (insert, update)
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func set(key: String, value: Any) -> MMSqliteMake {
        let model = operations.last?.1
        switch model.self {
        case is MMSqliteOperationInsertModel:
            (model as? MMSqliteOperationInsertModel)?.values[key] = value
        case is MMSqliteOperationUpdateModel:
            (model as? MMSqliteOperationUpdateModel)?.values[key] = value
        default:
            break
        }
        
        return self
    }
    
    
    
    /// where (select, update, delete)
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func whereEqual(key: String, value: Any) -> MMSqliteMake {
        var value = value
        if let _ = value as? String {
            value = "'\(value)'"
        }
        let model = operations.last?.1
        
        switch model.self {
        case is MMSqliteOperationSelectModel:
            (model as? MMSqliteOperationSelectModel)?.wheres.append("\(key)=\(value)")
        case is MMSqliteOperationUpdateModel:
            (model as? MMSqliteOperationUpdateModel)?.wheres.append("\(key)=\(value)")
        case is MMSqliteOperationDeleteModel:
            (model as? MMSqliteOperationDeleteModel)?.wheres.append("\(key)=\(value)")
        default:
            break
        }
        return self
    }
    
    /// whereLike (select, update, delete)
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func whereLike(key: String, value: Any) -> MMSqliteMake {
        var value = value
        if let _ = value as? String {
            value = "'%\(value)%'"
        } else {
            value = "%\(value)%"
        }
        let model = operations.last?.1
        switch model.self {
        case is MMSqliteOperationSelectModel:
            (model as? MMSqliteOperationSelectModel)?.wheres.append("\(key) like \(value)")
        case is MMSqliteOperationUpdateModel:
            (model as? MMSqliteOperationUpdateModel)?.wheres.append("\(key) like \(value)")
        case is MMSqliteOperationDeleteModel:
            (model as? MMSqliteOperationDeleteModel)?.wheres.append("\(key) like \(value)")
        default:
            break
        }
        return self
    }
}


//增加
fileprivate typealias __InsertMake = MMSqliteMake
extension __InsertMake {
    public func insert(values: [String: Any] = [:]) -> MMSqliteMake {
        let model = MMSqliteOperationInsertModel()
        operations.append((.insert, model))
        model.values = values
        return self
    }
}

//删除
fileprivate typealias __DeleteMake = MMSqliteMake
extension __DeleteMake {
    public func delete() -> MMSqliteMake {
        let model = MMSqliteOperationDeleteModel()
        operations.append((.delete, model))
        return self
    }
}

//修改
fileprivate typealias __UpdateMake = MMSqliteMake
extension __UpdateMake {
    public func update(values: [String: Any] = [:]) -> MMSqliteMake {
        let model = MMSqliteOperationUpdateModel()
        operations.append((.update, model))
        model.values = values
        return self
    }

}


//查询
fileprivate typealias __SelectMake = MMSqliteMake
extension __SelectMake {
    /// 查询数据
    /// - Parameter names: 需要查询的数据名称列表, 为空表示查询全部
    /// - Returns:
    public func select(names: [String] = []) -> MMSqliteMake {
        let model = MMSqliteOperationSelectModel()
        operations.append((.select, model))
        model.names = names
        return self
    }
    
}

fileprivate typealias __PrivateMake = MMSqliteMake
extension __PrivateMake {
    
    
    func getWheres(wheres: [String]) -> String {
        var whereStr = ""
        for i in 0 ..< wheres.count {
            if i != 0 {
                whereStr += ","
            }
            let condition = wheres[i]
            whereStr += "\(condition)"
        }
        return whereStr
    }
    
//MARK: sql语句拼接
    
    /// 插入sql语句
    /// - Parameter model:
    /// - Returns:
    func getInsertSql(model: MMSqliteOperationInsertModel) -> String {
        guard let name = tableName else {
            MMLOG.error("未设置表名")
            return ""
        }
//        var sql = ""
        var keysString = ""
        var valuesString = ""
        var i = 0
        for (key, value) in model.values {
            if i != 0 {
                keysString += ","
                valuesString += ","
            }
            keysString += key
            if let _ = value as? String {
                valuesString += "'\(value)'"
            } else {
                valuesString += "\(value)"
            }
            
            
            i += 1
        }
      
        
        if keysString.count > 0 {
            return "INSERT INTO \(name) (\(keysString)) VALUES (\(valuesString))"
        } else {
            MMLOG.error("未设置插入参数")
            return ""
        }
    }
    
    func getUpdateSql(model: MMSqliteOperationUpdateModel) -> String {
        guard let name = tableName else {
            MMLOG.error("未设置表名")
            return ""
        }
        var setValues = ""
        var i = 0
        for (key, value) in model.values {
            if i != 0 {
                setValues += ","
            }
            if let _ = value as? String {
                setValues += "\(key)='\(value)'"
            } else {
                setValues += "\(key)=\(value)"
            }
                
            
            i += 1
        }
        
        let whereStr = getWheres(wheres: model.wheres)
        
        if model.values.count > 0 {
            return "UPDATE \(name) SET \(setValues) WHERE (\(whereStr))"
        } else {
            return ""
        }
    }

    
    func getDeleteSql(model: MMSqliteOperationDeleteModel) -> String {
        guard let name = tableName else {
            MMLOG.error("未设置表名")
            return ""
        }
        let whereStr = getWheres(wheres: model.wheres)
        
        if model.wheres.count > 0 {
            return "DELETE FROM \(name) WHERE (\(whereStr))"
        } else {
            return "DELETE FROM \(name)"
        }
    }
    
    /// 查询语句
    /// - Parameter model: 查询model
    /// - Returns: sql
    func getSelectSql(model: MMSqliteOperationSelectModel) -> String {
        guard let name = tableName else {
            MMLOG.error("未设置表名")
            return ""
        }
        var selectNames = ""
        for i in 0 ..< model.names.count {
            let selectName = model.names[i]
            if i != 0 {
                selectNames += ","
            }
            selectNames += "\(selectName)"
        }
        
        let whereStr = getWheres(wheres: model.wheres)
        if selectNames.count == 0  {
            selectNames = "*"
        } else {
            selectNames = "\(selectNames)"
        }
        if model.wheres.count > 0 {
            return "SELECT \(selectNames) FROM \(name) WHERE (\(whereStr))"
        } else {
            return "SELECT \(selectNames) FROM \(name)"
        }
    }
    
    
    
}
