//
//  NSObject+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
public extension NSObject {
    
    /**
     获取对象的属性值，无对于的属性则返回NIL
     
     - parameter property: 要获取值的属性
     
     - returns: 属性的值
     */
    func mm_getValueOfProperty(_ property: String) -> AnyObject? {
        let allPropertys = mm_getAllPropertys()
        
        if(allPropertys.contains(property)) {
            return value(forKey: property) as AnyObject?
            
        } else {
            return nil
        }
    }
    
    /**
     设置对象属性的值
     
     - parameter property: 属性
     - parameter value:    值
     
     - returns: 是否设置成功
     */
    func mm_setValueOfProperty(_ property: String, value: AnyObject) -> Bool {
        let allPropertys = mm_getAllPropertys()
        if(allPropertys.contains(property)) {
            setValue(value, forKey: property)
            return true
            
        } else {
            return false
        }
    }
    
    /**
     获取对象的所有属性名称
     
     - returns: 属性名称数组
     */
    func mm_getAllPropertys() -> [String] {
        
        var result = [String]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        guard let buff = class_copyPropertyList(object_getClass(self), count) else {
            return result
        }
        
        let countInt = Int(count[0])
        
        for i in 0 ..< countInt {
            let temp = buff[i]
            let tempPro = property_getName(temp)
            if let proper = String.init(validatingUTF8: tempPro) {
                result.append(proper)
            }
        }
        return result
    }
    
    
    func mm_copy() -> Self {
        let obj = Self()
        let newObj = obj as NSObject
        
        let mirr = Mirror(reflecting: self)
        mirr.children.forEach { child in
            let childMirr = Mirror(reflecting: child)
            let name = child.label ?? ""
            let type = "\(childMirr.subjectType)"
            let value = child.value
            MMLOG.debug("name = \(name), type = \(type), value = \(value)")
            if let valueToArr = value as? [Any] {
                var newArr: [Any] = []
                valueToArr.forEach { obj in
                    if let nsObj = obj as? NSObject {
                        let copyObj = nsObj.mm_copy()
                        newArr.append(copyObj)
                    } else {
                        newArr.append(obj)
                    }
                }
                newObj.setValue(newArr, forKey: name)
            } else if let valueToDic = value as? [String: Any] {
                var newDic: [String: Any] = [:]
                valueToDic.forEach { (key: String, value: Any) in
                    if let nsObj = value as? NSObject {
                        newDic[key] = nsObj.mm_copy()
                    } else {
                        newDic[key] = value
                    }
                }
                newObj.setValue(newDic, forKey: name)
            } else if let valueToObj = value as? NSObject {
                newObj.setValue(valueToObj.mm_copy(), forKey: name)
            } else {
                //值类型的数据
                newObj.setValue(value, forKey: name)
            }
        }
        
        return obj
    }
    
    
    /// 字典转对象
    ///
    /// - Parameter sender: 传入字典
    func mm_translateObject(_ sender: NSMutableDictionary) {
        for (key, value) in sender {
            if let k = key as? String {
                setValue(value, forKey: k)
            }
        }
    }
    
    /// 对象转字符串
    ///
    /// - Returns: 生成的字符串
    func mm_getString() -> String {
        var str: String = ""
        if let arr = self as? NSArray {
            if arr.count != 0 {
                str = "["
                for i in 0 ..< arr.count {
                    let value = arr[i]
                    if let v = value as? String {
                        str += v
                    } else if let v = value as? Double {
                        str += String(v)
                    } else if let v = value as? Bool {
                        str += String(v)
                    } else if let v = value as? NSObject {
                        str += v.mm_getString()
                    }
                    if i < arr.count-1 {
                        str += ","
                    }
                }
                str += "]"
                return str
            }
            
        }
        
        str = "{"
        for i in 0 ..< mm_getAllPropertys().count {
            let item = mm_getAllPropertys()[i]
            let value = mm_getValueOfProperty(item)
            
            if let v = value as? String {
                str += item + ":" + v
            } else if let v = value as? Double {
                str += item + ":" + String(v)
            } else if let v = value as? Bool {
                str += item + ":" + String(v)
            } else if let v = value as? NSObject {
                str += item + ":" + v.mm_getString()
            }
            if i < mm_getAllPropertys().count-1 {
                str += ","
            }
        }
        
        str += "}"
        return str
    }
    
    
    
    /// 安全的valueforkey获取接口
    ///
    /// - Parameter key: key值
    /// - Returns: 获取的value
    func mm_safeValue(forKey key: String) -> Any? {
        let copy = Mirror(reflecting: self)
        
        for child in copy.children.makeIterator() {
            if let label = child.label, label == key {
                return child.value
            }
        }
        return nil
    }
}
