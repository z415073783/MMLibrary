//
//  MMFileCache.swift
//  MMLibrary
//
//  Created by zlm on 2021/8/13.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation

public protocol MMFileCacheProtocol: MMJSONCodable {
    init()
    var identifity: String { get }
}

let bundleID = Bundle.main.bundleIdentifier

open class MMFileCache {
    public static let share = MMFileCache()
    
    var needZip: Bool = false
    
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
        
        guard let data = try? JSONEncoder().encode(object) else {
            return false
        }
        let zipUrl = curPathUrl.appendingPathExtension("zip")
        
        if MMFileCache.share.needZip, let block = MMSetup.shared.zipBlock {
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
    // 删除文件
    open class func remove(identifity: String, path: String) -> Bool {
        guard var curPathUrl = checkPath(path: path) else {
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
        if FileManager.default.fileExists(atPath: curPathUrl.path) {
            let data = FileManager.default.contents(atPath: curPathUrl.path)
            return data?.getJSONModelSync(Class)
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

            let data = FileManager.default.contents(atPath: fileUrl.path)
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
                    if let data = FileManager.default.contents(atPath: _fileUrl.path), let model = data.getJSONModelSync(Class) {
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

