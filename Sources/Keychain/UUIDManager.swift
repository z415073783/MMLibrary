//
//  UUIDManager.swift
//  Odin-YMS
//
//  Created by zlm on 2017/10/12.
//

import UIKit

/// UUID获取工厂类
public class UUIDManager: NSObject {
    /// 获取UUID
    ///
    /// - Returns: 生成的UUID
    public class func getUUID() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
}
