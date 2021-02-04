//
//  MMSystem.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
public extension MMSystem {
    //版本比较
    enum CompareVersion {
        case greater, less, equal  //大于,小于,等于
    }

    
    //获取当前版本的前两位  例: 如当前版本为9.3.2,则返回9.3
    func getiOSVersion() -> Double {
        var version = UIDevice.current.systemVersion
        MMLOG.debug("UIDevice.current.systemVersion = \(version)")
        
        let arr = version.components(separatedBy: ".")
        if arr.count > 2 {
            version = arr[0] + "." + arr[1]
        }
        return Double(version)!
    }
    //判断当前版本是否大于等于传入版本
    func availableWithiOS(version: String) -> Bool {
        let sysVersion = UIDevice.current.systemVersion
        let arr = sysVersion.components(separatedBy: ".")
        let curArr = version.components(separatedBy: ".")
        var preGreater = false
        for i in 0 ..< curArr.count {
            if arr.count > i {
                if Int(arr[i])! < Int(curArr[i])! {
                    if preGreater == false {
                        return false
                    }
                } else if Int(arr[i])! >= Int(curArr[i])! {
                    preGreater = true
                }
            }
        }
        return true
    }

}

public class MMSystem: NSObject {
    
    //判断机型
    public let isIphone: Bool =  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
    public let isIpad: Bool = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    
    //判断横竖屏
    public let isPortrait: Bool = {
        return UIDevice.current.orientation.isPortrait
    }()
    public let isLandscape: Bool = {
        return UIDevice.current.orientation.isLandscape
    }()
    
    public class func logVersion() {
        
        MMLOG.debug("------------手机信息:\(getSystemData())------------")
        
    }
    
    public class func getAppName() -> String {
//        print("Bundle.main = \(Bundle.main.infoDictionary)")
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return "default"
    }
    
    //软件build版本
    public class func getSoftwareVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        
        return ""
    }
    
    public class func getVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let versionStr = String(format: "V%@(%@)", version, build)
            return versionStr
        }
        
        return ""
    }
    
    //比较两个版本,如果版本1大于版本2,则返回greater,如果小于版本less,则返回0,如果版本相等,则返回equal
    public class func compareVersion(version1: String, version2: String) -> CompareVersion {
        let version1List = version1.mm_split(".")
        let version2List = version2.mm_split(".")
        for i in 0 ..< version1List.count {
            if version2List.count <= i {
                return .greater
            }
            
            if i == (version1List.count - 1), (version2List.count - 1) > i {
                return .less
            }
            let cur1 = version1List[i]
            let cur2 = version2List[i]
            
            if cur1 > cur2 {
                return .greater
            } else if cur1 < cur2 {
                return .less
            }
        }
        return .equal
    }
    
    
    public class func getSystemData() -> String {
        let deviceName = UIDevice.current.name  //获取设备名称 例如：梓辰的手机
        let sysName = UIDevice.current.systemName //获取系统名称 例如：iPhone OS
        let sysVersion = UIDevice.current.systemVersion //获取系统版本 例如：9.2
        let deviceUUID = UIDevice.current.identifierForVendor?.uuid  //获取设备唯一标识符 例如：FBF2306E-A0D8-4F4B-BDED-9333B627D3E6
        let deviceModel = UIDevice.current.model //获取设备的型号 例如：iPhone
        let deviceModelName = UIDevice.current.mm_modelName //机型
        
        let result = "设备名称:\(deviceName) 系统名称:\(sysName) 系统版本:\(sysVersion) 设备标识:\(String(describing: deviceUUID)) 设备型号:\(deviceModel) 机型:\(deviceModelName) 客户端版本号:\(getVersion())"
        return result
    }
    
}
// MARK: - UIDevice延展
public extension UIDevice {
    
    var mm_modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,6":                              return "iPhone Xs Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
#endif
