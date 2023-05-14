//
//  MMLanguage.swift
//  MMLibrary
//
//  Created by mac on 2019/5/12.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
//语言改变
func mm_localized(key: String?) -> String {
    return MMLanguage.localized(key)
}
public extension String {
    var mm_localized: String {
        return MMLanguage.localized(self)
    }
    func mm_localized(language: MMLanguage.LanguageType) -> String {
        return MMLanguage.localized(self, selectLanguage: language)
    }
}

//public let kMMLanguageChangeNotification = NSNotification.Name("MMLanguageChangeNotification")
public extension MMLanguage {
    enum LanguageType: String {
        // 简体中午, 繁体中文, 英语, 西班牙语, 日语, 韩语, 意大利语, 德语
        case Chinese_Simplified = "zh-Hans", Chinese_Traditional = "zh-Hant", English = "en", Spanish = "es", Japanese = "ja", Korean = "ko", Italian = "it", German = "de"
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
            case "ja":
                return LanguageType.Japanese
            case "ko":
                return LanguageType.Korean
            case "it":
                return LanguageType.Italian
            case "de":
                return LanguageType.German
            default:
                return LanguageType.English
            }
        }
    }


    /// 转换语言
    ///
    /// - Parameter key: 默认语言
    /// - Returns: 当前语言
    static func localized(_ key: String?, identifity: String? = shared.identifityStr,  selectLanguage: LanguageType? = nil) -> String {
        guard let key = key else {
            return ""
        }
        var currentLanguage = MMLanguage.shared.kCurrentLanguage
        if selectLanguage != nil { //设置指定语言
            currentLanguage = selectLanguage?.rawValue
        }
        let newIdentifity = identifity ?? shared.identifityStr
        guard let plist = MMLanguage.shared.languagePlistDic[newIdentifity] else {
            
            MMAssert.fire("未获取到\(String(describing: identifity))对应的plist数据")
            return key
        }
        guard let dic = plist[key] else {
            MMLOG.error("language value获取失败 key: \(key)")
//            MMAssert.fire("language value获取失败 key: \(key)")
            return key
        }
        var language = ""
        if MMLanguage.shared.kCurrentLanguage == nil {
            var languages = Locale.preferredLanguages
            // 获取到当前首个支持的语言
            let defaultLanguage = Bundle.preferredLocalizations(from: languages)
            languages.insert(contentsOf: defaultLanguage, at: 0)
            MMLOG.info("系统语言优先级列表 = \(languages)") // TODO: 需要按优先级获取
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
                MMLOG.info("系统语言缩写 = \(_lan)")
                guard let _isExist = dic[_lan] else {
                    MMLOG.info("未匹配到\(_lan)语言资源")
                    continue
                }
                MMLOG.info("确定显示语言 = \(_lan)")
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
            if languageData.count == 0 {
                MMLOG.warn("languageData key:\(key) 为空字符串 language = \(language)")
            }
            return languageData
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
    
    public var kCurrentLanguageType: LanguageType? // = .English
    public var kCurrentLanguage: String? {
        set {
            guard let typeStr = newValue else {
                return
            }
            kCurrentLanguageType = LanguageType.getType(sender: typeStr)
        }
        get {
            return kCurrentLanguageType?.rawValue
        }
    }
    // 配置语言资源路径 必须在localized之前调用
    public var languageResourcePath = Bundle.main.path(forResource: "language", ofType: "plist")
    
    open var languagePlistName: [String: Bool] = [:]
    // 读取plist文件
    //    var languagePlist: [String:[String: String]] = [:]
    typealias LanguageIdentifity = String
    typealias LanguagePlistModel = [String:[String: String]]
    
    var languagePlistDic: [LanguageIdentifity: LanguagePlistModel] = [:]
    
    public class func initLanguageData(path: String? = shared.languageResourcePath, identifity: String = shared.identifityStr) {
        //工程文件路径
        guard let newPath = path else {
            MMLOG.error("MMLanguage.plist路径读取失败")
            return
        }
        //工程文件数据
        guard let data = NSDictionary(contentsOfFile: newPath) else {
            MMLOG.error("MMLanguage.plist读取失败")
            return
        }
        
        let list = path?.mm_split("/")
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = paths.first, let name = list?.last else { return }
        let namePath = path + "/" + name //翻译文件所在的沙盒路径
        shared.languagePlistName[name] = true
        
        //读取工程的翻译plist文件的版本号
        guard let projectLanguageVersion = data.value(forKey: "Version") as? String else {
            MMLOG.error("工程翻译plist版本号获取失败")
            return
        }
        //最新版本号
        var currentLanguageVersion = projectLanguageVersion
        
        var newData: NSDictionary = data //默认使用工程data数据
        //检查本地是否存在
        let isExist = FileManager.default.fileExists(atPath: namePath)
        if isExist {
            //读取本地
            if let _data = NSDictionary(contentsOfFile: namePath) {
                //对比版本
                guard let cacheLanguageVersion = newData.value(forKey: "Version") as? String else {
                    MMLOG.error("沙盒翻译plist版本号获取失败")
                    return
                }
                if MMLibrary.shared.isDebug {
                
                } else {
                    
                    //TODO: 版本判断
                    if MMSystem.compareVersion(version1: projectLanguageVersion, version2: cacheLanguageVersion) == MMSystem.CompareVersion.less {
                        //沙盒文件版本大于工程文件, 使用沙盒文件数据
                        currentLanguageVersion = cacheLanguageVersion
                        newData = _data
                    }
                    
                }
            } else {
                MMLOG.error("plist数据获取失败 namePath = \(namePath), 使用工程内plist文件")
            }
        } else {
//            沙盒文件不存在, 直接将工程文件写入沙盒(首次调用)
            newData.write(toFile: namePath, atomically: true)
        }
        
//        let recordV = recordVersion, recordV == curVersion

//        UserDefaults.standard.set(currentLanguageVersion, forKey: "Language_Version_Number-\(name)")
//        UserDefaults.standard.synchronize() //遗弃
        
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



