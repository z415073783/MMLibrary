//
//  MMFileCache.swift
//  MMLibrary
//
//  Created by zlm on 2021/8/13.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation

public class MMFileCacheCrypto: NSObject, MMJSONCodable {
    public var crypto: Bool = false //默认不加密
    public var cryptoKey: String = ""
}

public protocol MMFileCacheProtocol: MMJSONCodable {
    init()
    var identifity: String { get }
    
    func save(path: String) -> Bool
    func remove(path: String) -> Bool
    static func select<T: MMFileCacheProtocol>(identifity: String, path: String, crypto: MMFileCacheCrypto?) -> T?
    
    func zlm_copy<T: MMFileCacheProtocol>(Class: T.Type) -> T?
    
    var crypto: MMFileCacheCrypto { get }
}

public extension MMFileCacheProtocol {
    // 是否加密
    var crypto: MMFileCacheCrypto {
        return MMFileCacheCrypto()
    }
    
    @discardableResult func save(path: String) -> Bool {
        return MMFileCache.save(object: self, path: path)
    }
    
    @discardableResult func remove(path: String) -> Bool {
        return MMFileCache.remove(identifity: identifity, path: path)
    }
    
    static func select<T: MMFileCacheProtocol>(identifity: String, path: String, crypto: MMFileCacheCrypto?) -> T? {
        return MMFileCache.select(identifity: identifity, Class: self, path: path, crypto: crypto) as? T
    }
    
    func zlm_copy<T: MMFileCacheProtocol>(Class: T.Type) -> T? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return  data.getJSONModelSync(Class)
    }
}


let bundleID = Bundle.main.bundleIdentifier

open class MMFileCache {
    public static let share = MMFileCache()
    
    var needZip: Bool = false
    
    public let rootPath = MMFileData.getDocumentsPath()?.appendingPathComponent("MMFileCache")
    //检查路径是否存在
    open class func checkPath(path: String?, rootPath: URL? = share.rootPath, needCreate: Bool = false) -> URL? {
        let curPath: URL?
        if let path = path {
            curPath = rootPath?.appendingPathComponent(path)
        } else {
            curPath = rootPath
        }
        guard let curPath = curPath else {
            return nil
        }
        if needCreate == true {
            if MMFileData.createRecursionFolder(url: curPath) {
                return curPath
            } else {
                return nil
            }
        }
        if !FileManager.default.fileExists(atPath: curPath.path) {
            return nil
        }
        return curPath
    }
    
    
    
//    open var aesCustomKey: String = ""
    
    // 保存文件 会覆盖
    @discardableResult open class func save<T: MMFileCacheProtocol>(object: T, path: String?, rootPath: URL? = share.rootPath) -> Bool {
        guard var curPathUrl = checkPath(path: path, rootPath: rootPath, needCreate: true) else {
            return false
        }
        curPathUrl.appendPathComponent("\(object.identifity)")
        MMLOG.info("保存数据: \(curPathUrl.path)")
        
        guard var data = try? JSONEncoder().encode(object) else {
            return false
        }
        if object.crypto.crypto == true {
            // 需要加密
            data = data.aesEncryptData(customKey: object.crypto.cryptoKey) ?? data
        }
        
        if MMFileCache.share.needZip, let block = MMSetup.shared.zipBlock {
            let zipUrl = curPathUrl.appendingPathExtension("zip")
            do {
                if (FileManager.default.fileExists(atPath: zipUrl.path)) {
                    try FileManager.default.removeItem(at: zipUrl) //删除已有
                }
            } catch {
                MMLOG.error("删除已有失败")
            }
            block(object.identifity, data, zipUrl, bundleID ?? "")
        } else {
            do {
                try data.write(to: curPathUrl)
            } catch {
                MMLOG.error("写入失败 = \(error)")
            }
        }
        return true
    }
    // 更新指定文件的修改时间
    open class func changeDodificationDate(identifity: String, path: String?, rootPath: URL? = share.rootPath, goalDate: Date) {
        guard var curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            return
        }
        curPathUrl.appendPathComponent(identifity)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: curPathUrl.path)
            if var modificationDate = attributes[.modificationDate] as? Date {
                modificationDate = goalDate
                try FileManager.default.setAttributes([.modificationDate: modificationDate], ofItemAtPath: curPathUrl.path)
            }
        } catch {
            MMLOG.error("文件修改时间失败 = \(error)")
        }
    }
    
    // 删除文件
    open class func remove(identifity: String, path: String?, rootPath: URL? = share.rootPath) -> Bool {
        guard var curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            return false
        }
        curPathUrl.appendPathComponent(identifity)
        let zipUrl = curPathUrl.appendingPathExtension("zip")
        do {
            if FileManager.default.fileExists(atPath: curPathUrl.path) {
                try FileManager.default.removeItem(at: curPathUrl)
            }
            if FileManager.default.fileExists(atPath: zipUrl.path) {
                try FileManager.default.removeItem(at: zipUrl)
            }
            
            return true
        } catch {
            MMLOG.error("删除失败 error = \(error)")
        }
        
        return false
    }
    // 删除文件夹
    @discardableResult open class func remove(path: String?, rootPath: URL? = share.rootPath) -> Bool {
        guard let curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            MMLOG.error("文件夹不存在")
            return false
        }
        var isDirectory: ObjCBool = ObjCBool(false)
        if FileManager.default.fileExists(atPath: curPathUrl.path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.removeItem(at: curPathUrl)
                return true
            } catch {
                MMLOG.error("删除失败 error = \(error)")
            }
        }
        return false
    }
    
    
    // 读取文件
    open class func select<T: MMFileCacheProtocol>(identifity: String, Class: T.Type, path: String?, rootPath: URL? = share.rootPath, crypto: MMFileCacheCrypto?) ->T? {
        guard var curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            return nil
        }
        curPathUrl.appendPathComponent("\(identifity)")
        MMLOG.debug("读取文件目录: \(curPathUrl)")
        if FileManager.default.fileExists(atPath: curPathUrl.path) {
            guard var data = FileManager.default.contents(atPath: curPathUrl.path) else {
                return nil
            }
            if let crypto = crypto, crypto.crypto == true {
                data = aesDecryptData(data: data, crypto: crypto) ?? data
            }
            return data.getJSONModelSync(Class)
        }
        
        let zipUrl = curPathUrl.appendingPathExtension("zip")
        if FileManager.default.fileExists(atPath: zipUrl.path) {
            let lastFilePath = String(curPathUrl.path.dropLast(1 + curPathUrl.lastPathComponent.count))
            guard let lastFileUrl = URL(string: lastFilePath) else {
                return nil
            }
            guard let fileUrl = MMSetup.shared.unZipBlock?(zipUrl, lastFileUrl, true, bundleID ?? "") else {
                return nil
            }

            guard var data = FileManager.default.contents(atPath: fileUrl.path) else {
                return nil
            }
            if let crypto = crypto, crypto.crypto == true {
                data = aesDecryptData(data: data, crypto: crypto) ?? data
            }
            
            return data.getJSONModelSync(Class)
        }
        return nil
    }
    
    open class func selectItemFileInfo(identifity: String, path: String?, rootPath: URL? = share.rootPath) -> [FileAttributeKey : Any] {
        guard var curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            return [:]
        }
        curPathUrl.appendPathComponent("\(identifity)")
        do {
            let info = try FileManager.default.attributesOfItem(atPath: curPathUrl.path)
            return info
        } catch {
            MMLOG.error("error = \(error)")
            return [:]
        }
    }
    
//    读取指定路径下的所有文件
    open class func selectAllItem<T: MMFileCacheProtocol>(Class: T.Type, path: String?, rootPath: URL? = share.rootPath, crypto: MMFileCacheCrypto?) ->[T] {
        guard let curPathUrl = checkPath(path: path, rootPath: rootPath) else {
            return []
        }
        do {
            var resultList: [T] = []
            let itemPathList = try FileManager.default.contentsOfDirectory(at: curPathUrl, includingPropertiesForKeys: nil, options: [])
            itemPathList.forEach { itemUrl in
                if FileManager.default.fileExists(atPath: itemUrl.path) {
                    
                    let lastFileUrl = itemUrl.deletingLastPathComponent()
                    let targeUrl = itemUrl.deletingPathExtension()
                    var fileUrl: URL?
                    if (FileManager.default.fileExists(atPath: targeUrl.path)) {
                        fileUrl = targeUrl
                    } else {
                        fileUrl = MMSetup.shared.unZipBlock?(itemUrl, lastFileUrl, true, bundleID ?? "")
                    }
                    
                    guard let _fileUrl = fileUrl else {
                        return
                    }
                    guard var data = FileManager.default.contents(atPath: _fileUrl.path) else {
                        return
                    }
                    if let crypto = crypto, crypto.crypto == true {
                        data = aesDecryptData(data: data, crypto: crypto) ?? data
                    }
                    if let model = data.getJSONModelSync(Class) {
                        resultList.append(model)
                    } else {
                        MMLOG.error("数据解析错误")
                    }
                }
            }
            return resultList
        } catch {
            MMLOG.error("error = \(error)")
        }
        return []
    }

    open class func aesDecryptData(data: Data, crypto: MMFileCacheCrypto) -> Data? {
        let decryptData = data.aesDecryptData(customKey: crypto.cryptoKey)
        return decryptData
    }
    
}

