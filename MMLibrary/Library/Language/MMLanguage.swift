//
//  MMLanguage.swift
//  MMLibrary
//
//  Created by mac on 2019/5/12.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
//语言改变
//    func localized(key: String?) -> String {
//        return localized(key: key)
//    }

//public let kMMLanguageChangeNotification = NSNotification.Name("MMLanguageChangeNotification")
public extension MMLanguage {
    enum LanguageType: String {
        case Chinese_Simplified = "zh-Hans", Chinese_Traditional = "zh-Hant", English = "en", Spanish = "es"
        static func getType(sender: String) -> LanguageType {
            switch sender {
            case "zh-Hans":
                return LanguageType.Chinese_Simplified
            case "zh-Hant":
                return LanguageType.Chinese_Traditional
            case "en":
                return LanguageType.English
            case "es":
                return LanguageType.Spanish
            default:
                return LanguageType.English
            }
        }
    }


    /// 转换语言
    ///
    /// - Parameter key: 默认语言
    /// - Returns: 当前语言
    func localized(_ key: String?,_ identifity: String? = shared.identifityStr, _ selectLanguage: LanguageType? = nil) -> String {
        guard let key = key else {
            return ""
        }
        var currentLanguage = MMLanguage.shared.kCurrentLanguage
        if selectLanguage != nil { //设置指定语言
            currentLanguage = selectLanguage?.rawValue
        }
        let newIdentifity = identifity ?? identifityStr
        guard let plist = MMLanguage.shared.languagePlistDic[newIdentifity] else {
            MMLOG.error("未获取到\(String(describing: identifity))对应的plist数据")
            return key
        }
        guard let dic = plist[key] else {
            MMLOG.error("language value获取失败 key: \(key)")
            return key
        }
        var language = ""
        if MMLanguage.shared.kCurrentLanguage == nil {
            let languages = Locale.preferredLanguages
            language = languages[0]
            let list = language.components(separatedBy: "-") as [String]
            var isHaveData = false
            for i in (0 ..< list.count).reversed() {
                var _lan = ""
                for j in 0 ... i {
                    if j == 0 {
                        _lan = list[j]
                    }else {
                        _lan += ("-" + list[j])
                    }
                }
                guard let _isExist = dic[_lan] else {
                    continue
                }
                language = _lan
                MMLanguage.shared.kCurrentLanguage = language
                isHaveData = true
                if _isExist.count != 0 {
                    return _isExist
                } else {
                    break
                }
            }
            // 当前系统语种不在软件适配列表中
            if isHaveData == false {
                MMLOG.info("当前系统语种不在软件适配列表中")
                language = "en"
                MMLanguage.shared.kCurrentLanguage = language //设为默认:英语
            }
        }else {
            language = currentLanguage ?? ""
        }
        
        if let languageData = dic[language] {
            if languageData.count > 0 {
                return languageData
            }
        }
        
        //获取英语
        language = "en"
        guard let enData = dic[language] else {
            MMLOG.error("获取英语翻译失败 key:\(key) dic:\(dic)")
            return key
        }
        if enData.count == 0 {
            MMLOG.error("获取英语翻译数据长度为0 key:\(key)")
            return key
        }
        return enData
    }
}


@objc public class MMLanguage: NSObject {
    public static let shared = MMLanguage()
    public let identifityStr = "default"

    public var kCurrentLanguageType: LanguageType = .English
    private var _kCurrentLanguage: String? = nil
    public var kCurrentLanguage: String? {
        set {
            _kCurrentLanguage = newValue
            guard let typeStr = newValue else {
                return
            }
            kCurrentLanguageType = LanguageType.getType(sender: typeStr)
        }
        get {
            return _kCurrentLanguage
        }
    }
    // 配置语言资源路径 必须在localized之前调用
    public var languageResourcePath = Bundle.main.path(forResource: "YLLanguage", ofType: "plist")
    
    open var languagePlistName: [String: Bool] = [:]
    // 读取plist文件
    //    var languagePlist: [String:[String: String]] = [:]
    typealias LanguageIdentifity = String
    typealias LanguagePlistModel = [String:[String: String]]
    
    var languagePlistDic: [LanguageIdentifity: LanguagePlistModel] = [:]
    
    public class func initLanguageData(path: String? = shared.languageResourcePath, identifity: String = shared.identifityStr) {
        guard let newPath = path else {
            MMLOG.error("YLLanguage.plist路径读取失败")
            return
        }
        guard let data = NSDictionary(contentsOfFile: newPath) else {
            MMLOG.error("YLLanguage.plist读取失败")
            return
        }
        
        let list = path?.MMsplit("/")
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = paths.first, let name = list?.last else { return }
        let namePath = path + "/" + name
        shared.languagePlistName[name] = true
        let recordVersion = UserDefaults.standard.string(forKey: "Language_Version_Number-\(name)")
        let curVersion = MMSystem.getVersion()
        
        var newData: NSDictionary = data
        //检查本地是否存在
        let isExist = FileManager.default.fileExists(atPath: namePath)
        if isExist, let recordV = recordVersion, recordV == curVersion {
            //读取本地
            if let _data = NSDictionary(contentsOfFile: namePath) {
                #if DEBUG
                #else
                newData = _data
                #endif
            } else {
                MMLOG.error("plist数据获取失败 namePath = \(namePath), 使用工程内plist文件")
            }
        } else {
            //            写入本地
            newData.write(toFile: namePath, atomically: true)
        }
        UserDefaults.standard.set(curVersion, forKey: "Language_Version_Number-\(name)")
        UserDefaults.standard.synchronize()
        
        guard let languageData = newData.value(forKey: "Language") as? NSDictionary else {
            MMLOG.error("Language资源读取失败")
            return
        }
        
        
        // 获取数据加入已有数据中
        var newPlist: LanguagePlistModel = shared.languagePlistDic[identifity] ?? [:]
        for (key, value) in languageData {
            guard let lanDic = value as? NSDictionary else {
                continue
            }
            var lanValues: [String: String] = [:]
            for (lanKey, lanValue) in lanDic {
                guard let _lanKey = lanKey as? String else {
                    continue
                }
                guard let _lanValue = lanValue as? String else {
                    continue
                }
                lanValues[_lanKey] = _lanValue
            }
            guard let _key = key as? String else {
                continue
            }
            newPlist[_key] = lanValues
            //            getInstance.languagePlist[_key] = lanValues
        }
        shared.languagePlistDic[identifity] = newPlist
        
    }
}



