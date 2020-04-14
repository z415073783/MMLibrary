//
//  MMSqliteLint.swift
//  MMLibrary
//
//  Created by zlm on 2020/3/27.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation


enum MMSqliteOperationType {
    case createTable, select, insert, delete, update
}

class MMSqliteOperationModel {
    
}
class MMSqliteOperationCreateModel: MMSqliteOperationModel {
    //保存索引属性列表
     fileprivate var propertys: [(String, [MMSqliteOperationPropertyType])] = []
}


class MMSqliteOperationSelectModel: MMSqliteOperationModel {
    //保存需要查询的数据名称
    fileprivate var names: [String] = []
    fileprivate var wheres: [String] = []
}
class MMSqliteOperationInsertModel: MMSqliteOperationModel {
    fileprivate var values: [String: String] = [:]
}
class MMSqliteOperationUpdateModel: MMSqliteOperationModel {
    fileprivate var values: [String: String] = [:]
    fileprivate var wheres: [String] = []
}
class MMSqliteOperationDeleteModel: MMSqliteOperationModel {
    fileprivate var wheres: [String] = []
}


public class MMSqliteMake: NSObject {
    lazy var _sqliteObj = MMSqlite()
    
//    fileprivate init() {
//    }
    //表名
    fileprivate var tableName: String?
    
//    weak fileprivate var link: MMSqliteLink?
    //保存操作队列
    fileprivate var operations: [(MMSqliteOperationType, MMSqliteOperationModel)] = []
 
    
    //设置表名
    public func tableName(name: String) -> MMSqliteMake {
//       let make = MMSqliteMake()
       self.tableName = name
       return self
    }
    
    //执行
    public func execute(block:@escaping (_ isSuccess: Bool,_ result: NSMutableArray) ->Void) {
//        let _block = block
        for operation in operations {
            guard let name = tableName else {
                block(false, [])
                return
            }
            switch operation.0 {
            case .createTable:
                
                guard let model = operation.1 as? MMSqliteOperationCreateModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.createTable(name, parames: model.propertys, block: { (isOk) in
                    MMLOG.info("创建表: \(name), \(isOk)")
                    block(isOk, [])
                })
            case .select:
               
                guard let model = operation.1 as? MMSqliteOperationSelectModel else {
                    block(false, [])
                    return
                }
                
                _sqliteObj.select(getSelectSql(model: model), self.description) { (resultList) in
                    block(true, resultList)
                }
            case .insert:
                guard let model = operation.1 as? MMSqliteOperationInsertModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.update(getInsertSql(model: model), self.description) { (isOk) in
                    block(isOk, [])
                }
            case .delete:
                
                break
            case .update:
               
                break
            }
        }
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
    
    
    //打开数据库
    public init(name: String, path: String = MMFileData.getDocumentsPath(), block: @escaping ((_ isSuccess: Bool, _ link: MMSqliteLink?) -> Void)) {
        super.init()
        let fullPath = path + "/" + name
        MMLOG.debug("path/name = \(fullPath)")
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
            model.propertys.append((name,[]))
        }
        return self
    }
    public var primarykey: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.primarykey)
            }
        }
        
        return self
    }
    public var autoincrement: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.autoincrement)
            }
        }
        
        return self
    }
    public var unique: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.unique)
            }
        }
        
        return self
    }
    public var integer: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.integer)
            }
        }
        return self
    }
    public var text: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.text)
            }
        }
        return self
    }
    public var float: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if var set = model.propertys.last {
                set.1.append(.float)
            }
        }
        return self
    }
        
}


fileprivate typealias __CommonMake = MMSqliteMake
extension __CommonMake {
    
    public func set(key: String, value: String) -> MMSqliteMake {
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
    
    
    //条件
    public func whereEqual(key: String, value: String) -> MMSqliteMake {
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
    public func whereLike(key: String, value: String) -> MMSqliteMake {
        let model = operations.last?.1
        switch model.self {
        case is MMSqliteOperationSelectModel:
            (model as? MMSqliteOperationSelectModel)?.wheres.append("\(key) like \(value)")
        case is MMSqliteOperationUpdateModel:
            (model as? MMSqliteOperationUpdateModel)?.wheres.append("\(key) like \(value)")
        default:
            break
        }
        return self
    }
}


//增加
fileprivate typealias __InsertMake = MMSqliteMake
extension __InsertMake {
    public func insert(values: [String: String] = [:]) -> MMSqliteMake {
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
    public func update(values: [String: String] = [:]) -> MMSqliteMake {
        let model = MMSqliteOperationUpdateModel()
        operations.append((.update, model))
        model.values = values
        return self
    }

}


//查询
fileprivate typealias __SelectMake = MMSqliteMake
extension __SelectMake {
    //查询命令
//    public var select: MMSqliteMake {
//        operations.append(MMSqliteOperationType.select)
//        return self
//    }
    
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
            valuesString += value
            
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
            setValues += "\(key)=\(value)"
            i += 1
        }
        
        let whereStr = getWheres(wheres: model.wheres)
        
        if model.values.count > 0 {
            return "UPDATE (\(name)) SET \(setValues) WHERE (\(whereStr))"
        } else {
            return ""
        }
    }
    
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
    
    func getDeleteSql(model: MMSqliteOperationDeleteModel) -> String {
        guard let name = tableName else {
            MMLOG.error("未设置表名")
            return ""
        }
        let whereStr = getWheres(wheres: model.wheres)
        
        if model.wheres.count > 0 {
            return "DELETE FROM \(name) WHERE (\(whereStr))"
        } else {
            return ""
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
            selectNames = "(\(selectNames))"
        }
        if model.wheres.count > 0 {
            return "SELECT (\(selectNames)) FROM \(name) WHERE (\(whereStr))"
        } else {
            return "SELECT (\(selectNames)) FROM \(name)"
        }
    }
}
