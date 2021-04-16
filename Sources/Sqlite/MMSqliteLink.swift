//
//  MMSqliteLint.swift
//  MMLibrary
//
//  Created by zlm on 2020/3/27.
//  Copyright © 2020 zlm. All rights reserved.
// 链式结构封装层

import Foundation


enum MMSqliteOperationType {
    case createTable, deleteTable, select, insert, replace, delete, update
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
    public var isQueue: Bool {
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
    //执行 queue == nil 不开启多线程
    public func execute(queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool,_ result: NSMutableArray) ->Void) {

        guard let name = tableName else {
            block(false, [])
            return
        }
    
        
        
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
            case .deleteTable:
//                guard let model = operation.1 as? MMSqliteOperationCreateModel else {
//                    block(false, [])
//                    return
//                }
                _sqliteObj.deleteTable(name, queue: queue, block: { (isOk) in
                    MMLOG.info("删除表: \(name), \(isOk)")
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
            case .replace:
                guard let model = operation.1 as? MMSqliteOperationInsertModel else {
                    block(false, [])
                    return
                }
                _sqliteObj.update(getReplaceSql(model: model), queue: queue) { (isOk) in
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
//    String()
    public init(name: String, path: URL? = MMFileData.getDocumentsPath()?.appendingPathComponent("MMSqlite"), isQueue: Bool = false, block: @escaping ((_ isSuccess: Bool, _ link: MMSqliteLink?) -> Void)) {
        super.init()
        guard let path = path else {
            MMLOG.debug("path参数为nil")
            return
        }
        let sqlitePath = path
        if !FileManager.default.fileExists(atPath: sqlitePath.path) {
            do {
                try FileManager.default.createDirectory(at: sqlitePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                MMLOG.error("error = \(error)")
            }
        }
        let fullPath = path.appendingPathComponent(name)
        MMLOG.debug("path/name = \(fullPath)")
        self._sqliteObj.isQueue = isQueue
        self._sqliteObj.openSqlWithPath(fullPath) { [weak self](isOk) in
//            self?._make.link = self
            block(isOk, self ?? nil)
        }
    }
    
    
    
}


extension String {
    func removeOptional() -> (String, Bool) {
        if self.hasPrefix("Optional") {
            let result = self[self.index(self.startIndex, offsetBy: "Optional(".count) ..< self.index(self.endIndex, offsetBy: -(")".count))]
            return (String(result), true)
        }
        return (self, false)
    }
    
    func isOptionType() -> Bool {
        if self.hasPrefix("Optional") {
            return true
        }
        return false
    }
}

fileprivate typealias __TableModelMake = MMSqliteMake
extension __TableModelMake {
    func optionValue(value: Any?, type: Any.Type) -> Any? {
        if let newValue = value as? Int {
            return newValue
        } else if let newValue = value as? Double {
            return newValue
        } else if let newValue = value as? Float {
            return newValue
        } else if let newValue = value as? String {
            return newValue
        } else if let newValue = value as? Data {
            return newValue
        } else if let newValue = value as? Bool {
            return newValue
        } else {
            //数据为nil
            switch "\(type)" {
            case "Int", "Optional<Int>":
                return 0
            case "Double", "Optional<Double>":
                return 0.0
            case "Float", "Optional<Float>":
                return 0.0
            case "String", "Optional<String>":
                return ""
            case "Data", "Optional<Data>":
                return Data()
            case "Bool", "Optional<Bool>":
                return false
            default:
                MMLOG.error("未处理类型 => \(type)")
                return nil
            }
        }
    }
    
    func getValues<T: MMJSONCodable>(bodyClass: T) -> [String: Any] {
        var values: [String: Any] = [:]
        let mir = Mirror(reflecting: bodyClass)
        let children = mir.children
        children.forEach { (child) in
            let childMir = Mirror(reflecting: child.value)
            //变量名
            let name = child.label ?? ""
            let type = "\(childMir.subjectType)"
//            MMLOG.error("name = \(name), type = \(type), value = \(child.value)")
            
            var value = child.value
            if type.isOptionType() {
                
                if let _value = optionValue(value: value, type: childMir.subjectType) {
                    value = _value
                } else {
                    //不存在
                    return
                }
            }
            
            if name == "identify" {
                //identify为0, 自动赋值
                guard let valueInt = value as? Int, valueInt != 0 else {
                    return
                }
                values[name] = valueInt
            } else {
                values[name] = value
            }
        }
        return values
    }
 
    
}
public extension __TableModelMake {
    //通过model创建属性
    func createTable<T: MMSqliteProtocol>(bodyClass: T.Type, queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) ->Void) {
        _ = createTable
        
        let mir = Mirror(reflecting: T())
        let children = mir.children
        children.forEach { (child) in
            let childMir = Mirror(reflecting: child.value)
            //变量名
            let name = child.label ?? ""
            let type = "\(childMir.subjectType)"
            MMLOG.error("name = \(name), type = \(type)")
        
            _ = self.property(name: name)
            switch type {
            case "Int", "Optional<Int>":
                if name == "identify" {
                    _ = self.primarykey.integer.autoincrement
                } else {
                    _ = self.integer
                }
            case "Double", "Optional<Double>":
                _ = self.real
            case "Float", "Optional<Float>":
                _ = self.float
            case "String", "Optional<String>":
                _ = self.text
            case "Data", "Optional<Data>":
                _ = self.none
            case "Bool", "Optional<Bool>":
                _ = self.numeric
            case "Numeric", "Optional<Numeric>":
                _ = self.numeric
            default:
                MMLOG.error("未处理类型 => \(type), name = \(name)")
                break
            }

        }
        self.execute(queue: queue) { (finish, list) in
            block(finish)
        }
    }
    
    //通过model添加属性
    func insert<T: MMSqliteProtocol>(bodyClass: T, queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) ->Void) {
        let values = getValues(bodyClass: bodyClass)
        insert(values: values).execute(queue: queue) { (finish, list) in
            block(finish)
        }
    }
    //通过model添加(更新)属性 根据唯一标识符判断是否是添加或者更新
    func replace<T: MMSqliteProtocol>(bodyClass: T, queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool) ->Void) {
        let values = getValues(bodyClass: bodyClass)
        replace(values: values).execute(queue: queue) { (finish, list) in
            block(finish)
        }
    }
    //目前只支持单条件查询
    func select<T: MMSqliteProtocol>(bodyClass: T.Type, confitions: [String: Any] = [:], queue: OperationQueue? = nil, block:@escaping (_ isSuccess: Bool, _ list: [T]) ->Void) {
    
        _ = select(names: [])
        for (key, value) in confitions {
            _ = whereEqual(key: key, value: value)
        }
        execute(queue: queue) { (finish, list) in
            if !finish {
                block(finish, [])
                return
            }
            var result: [T] = []
            
            for item in list {
                guard let dic = item as? NSMutableDictionary else {
                    continue
                }
                //遍历类型, 把bool类型的数据 数字 转换成 false和true
                let mir = Mirror(reflecting: T())
                let children = mir.children
                children.forEach { (child) in
                    let childMir = Mirror(reflecting: child.value)
                    //变量名
                    let name = child.label ?? ""
                    let type = "\(childMir.subjectType)"
                    
                    switch type {
                    case "Bool", "Optional<Bool>":
                        if let curValue = dic[name] as? Int {
                            let newValue: Bool = curValue == 0 ? false : true
                            dic[name] = newValue
                        }
                    default:
                        break
                    }
                    
            
                        
//                        values[name] = value
                    
                }
                
                
                
                guard let model = dic.getJSONModelSync(bodyClass) else {
                    continue
                }
                
                
                result.append(model)
            }
            block(finish, result)
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
    //删除表命令
    public var deleteTable: MMSqliteMake {
        operations.append((MMSqliteOperationType.deleteTable, MMSqliteOperationModel()))
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
    
    /// 双精度
    public var real: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.real)
            }
        }
        return self
    }
    
    /// 日期 时间 bool
    public var numeric: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.numeric)
            }
        }
        return self
    }
    public var bool: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.numeric)
            }
        }
        return self
    }
    
    //二进制数据 data
    public var none: MMSqliteMake {
        if let model = operations.last?.1 as? MMSqliteOperationCreateModel {
            if let set = model.propertys.last {
                set.types.append(.none)
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
fileprivate typealias __ReplaceMake = MMSqliteMake
extension __ReplaceMake {
    
    /// 插入或者更新
    /// - Parameter values: values description
    /// - Returns: description
    public func replace(values: [String: Any] = [:]) -> MMSqliteMake {
        let model = MMSqliteOperationInsertModel()
        operations.append((.replace, model))
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
    func getReplaceSql(model: MMSqliteOperationInsertModel) -> String {
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
            return "REPLACE INTO \(name) (\(keysString)) VALUES (\(valuesString))"
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
            
            return "UPDATE \(name) SET \(setValues) \(whereStr.count > 0 ? "WHERE (\(whereStr))" : "")"
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
