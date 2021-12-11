//
//  MMFileCache.swift
//  MMLibrary
//
//  Created by zlm on 2021/8/13.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
import MMZipArchive

public protocol MMFileCacheProtocol: MMJSONCodable {
    init()
    var identifity: String { get }
}


open class MMFileCache {
    public static let share = MMFileCache()
    
    public let rootPath = MMFileData.getDocumentsPath()?.appendingPathComponent("MMFileCache")
    //检查路径是否存在
    open class func checkPath(path: String, needCreate: Bool = false) -> URL? {
        guard let curPath = share.rootPath?.appendingPathComponent(path) else {
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
    
    // 保存文件 会覆盖
    @discardableResult open class func save<T: MMFileCacheProtocol>(object: T, path: String) -> Bool {
        guard var curPathUrl = checkPath(path: path, needCreate: true) else {
            return false
        }
        curPathUrl.appendPathComponent("\(object.identifity)")
        MMLOG.info("保存数据: \(curPathUrl.path)")

        guard let data = try? JSONEncoder().encode(object), let zipUrl = URL(string: curPathUrl.path + ".zip") else {
            return false
        }
        do {
            try data.write(to: curPathUrl, options: Data.WritingOptions.noFileProtection)
            do {
                if (FileManager.default.fileExists(atPath: zipUrl.path)) {
                    try FileManager.default.removeItem(at: zipUrl) //删除已有
                }
                try MMZip.zipFiles(paths: [curPathUrl], zipFilePath: zipUrl, password: "900827") { progress in
                }
                try FileManager.default.removeItem(at: curPathUrl)
            } catch {
                MMLOG.error("压缩失败");
            }
        } catch {
            MMLOG.error("文件写入失败: \(error)")
            return false
        }
        return true
    }
    // 删除文件
    open class func remove(identifity: String, path: String) -> Bool {
        guard var curPathUrl = checkPath(path: path) else {
            return false
        }
        curPathUrl.appendPathComponent(identifity)
        guard let zipUrl = URL(string: curPathUrl.path + ".zip") else {
            return false
        }
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
    open class func remove(path: String) -> Bool {
        guard let curPathUrl = checkPath(path: path) else {
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
    open class func select<T: MMFileCacheProtocol>(identifity: String, Class: T.Type, path: String) ->T? {
        guard var curPathUrl = checkPath(path: path) else {
            return nil
        }
        curPathUrl.appendPathComponent("\(identifity)")
        guard let zipUrl = URL(string: curPathUrl.path + ".zip") else {
            return nil
        }
        
        if FileManager.default.fileExists(atPath: zipUrl.path) {
            do {
                try MMZip.unzipFile(zipUrl, destination: curPathUrl, overwrite: true, password: "900827") { progress in
                    
                } fileOutputHandler: { unzippedFile in
                    
                }
            } catch {
                MMLOG.error("解压失败 => \(zipUrl.path)");
            }

            let data = FileManager.default.contents(atPath: curPathUrl.path)
            return data?.getJSONModelSync(Class)
        }
        return nil
    }
//    读取指定路径下的所有文件
    open class func selectAllItem<T: MMFileCacheProtocol>(Class: T.Type, path: String) ->[T] {
        guard let curPathUrl = checkPath(path: path) else {
            return []
        }
        do {
            var resultList: [T] = []
            let itemPathList = try FileManager.default.contentsOfDirectory(at: curPathUrl, includingPropertiesForKeys: nil, options: [])
            itemPathList.forEach { itemUrl in
                if FileManager.default.fileExists(atPath: itemUrl.path) {
                    if let data = FileManager.default.contents(atPath: itemUrl.path), let model = data.getJSONModelSync(Class) {
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
    
    
    
    
    
    
    
    
}

