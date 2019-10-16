//
//  NSObject+ClassName.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// 获取对象实例的id，类似指针
    ///
    /// - Returns: 对象实例的id
    public func mm_getAddressIdentifity() -> String {
        let address: CVarArg = self as CVarArg
        let targetDes = String(format: "%018p", address)
        return targetDes
    }
    
    /// 获取对象类名
    ///
    /// - Returns: 类名
    public class func mm_className() -> String {
        return String(describing: self)
    }
    
    
    /// 获取实例类名
    ///
    /// - Returns: 类名
    public func mm_className() -> String {
        return String(describing: type(of: self))
    }
    
    /// 依据ClassName获取Class
    ///
    /// - Parameter className: className
    /// - Returns: Class
    public class func mm_swiftClass(fromClassName className: String) -> AnyClass? {
        /// get namespace
        if let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String {
            var fixedNamespace = namespace.replacingOccurrences(of: " ", with: "_")
            fixedNamespace = fixedNamespace.replacingOccurrences(of: "-", with: "_")
            
            let swiftClassName = "\(fixedNamespace).\(className)"
            if let clazz = NSClassFromString(swiftClassName) {
                return clazz
            }
        }
        
        // get the project name
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
            var fixedAppName = appName.replacingOccurrences(of: " ", with: "_")
            fixedAppName = fixedAppName.replacingOccurrences(of: "-", with: "_")
            
            var swiftClassName = "_TtC\(fixedAppName.count)\(fixedAppName)\(className.count)\(className)"
            if let clazz = NSClassFromString(swiftClassName) {
                return clazz
            }
            
            swiftClassName = "\(fixedAppName).\(className)"
            if let clazz = NSClassFromString(swiftClassName) {
                return clazz
            }
        }
        
        if let clazz = NSClassFromString(className) {
            return clazz
        }
        
        return nil
    }
}
