//
//  UUIDManager.swift
//
//  Created by zlm on 2017/10/12.
//
#if !os(macOS)
import UIKit
/// UUID获取工厂类
public class UUIDManager: NSObject {
    /// 获取UUID
    ///
    /// - Returns: 生成的UUID
    public class func getUUID() -> String {
        return "" //需要授权
    }
}

#endif


