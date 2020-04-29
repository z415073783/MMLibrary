//
//  MMFileData.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif
open class MMFileData: NSObject {
    // MARK: 创建文件夹
    open class func createLocalSupportDicPath(dicName: String) -> Bool {
        guard let localPath = MMFileData.getLocalSupportPath() else {
            MMLOG.error("获取supportPath失败")
            return false
        }
        
        let createPath = localPath.appendingPathComponent(dicName)
        do {
            try FileManager.default.createDirectory(at: createPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
            return false
        }
        return true
    }
    
    // MARK: 创建文件
    open class func createLocalSupportFile(dicName: String, file: String) -> Bool {
        guard let localPath = MMFileData.getLocalSupportPath() else {
            MMLOG.error("获取supportPath失败")
            return false
        }
        let dicPath = localPath.appendingPathComponent(dicName)
        let isExist = FileManager.default.fileExists(atPath: dicPath.path)
        if !isExist {
            let isSuucess = MMFileData.createLocalSupportDicPath(dicName: dicName)
            if !isSuucess {
                MMLOG.error("\(dicPath) create is fail!")
                return false
            }
        }
        let createPath = dicPath.appendingPathComponent(file)
        return FileManager.default.createFile(atPath: createPath.path, contents: nil, attributes: nil)
    }
    
    // MARK: 读取文件
    open class func readLocalSupportFile(dicName: String, file: String) -> String? {
        guard let localPath = MMFileData.getLocalSupportPath() else {
            MMLOG.error("获取supportPath失败")
            return nil
        }
        let writePath = localPath.appendingPathComponent(dicName).appendingPathComponent(file)
        
//        let writePath = localPath+"/"+dicName+"/"+file
        
        let isExist = FileManager.default.fileExists(atPath: writePath.path)
        if !isExist {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: writePath.path) {
            let dataStr = String(data: data, encoding: String.Encoding.utf8)
            return dataStr
        }
        
        return nil
    }
    
    // MARK: 写入文件
    open class func writeLocalSupportFile(dicName: String, file: String, data: String) -> Bool {
        guard let localPath = MMFileData.getLocalSupportPath() else {
            MMLOG.error("获取supportPath失败")
            return false
        }
        let writePath = localPath.appendingPathComponent(dicName).appendingPathComponent(file)
        let isExist = FileManager.default.fileExists(atPath: writePath.path)
        if !isExist {
            let isSuccess = MMFileData.createLocalSupportFile(dicName: dicName, file: file)
            if !isSuccess {
                MMLOG.error("\(writePath) create is fail!")
                return false
            }
        }
        
        do {
            try data.write(to: writePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            MMLOG.error("\(writePath) write is fail!")
            return false
        }
        return true
    }
    
    // MARK: 获取本地路径
    open class func getLocalLibraryPath() -> URL? {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return paths.first
    }
    open class func getLocalSupportPath() -> URL? {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return paths.first
    }
    open class func getLocalCachesPath() -> URL? {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return paths.first
    }
    
    open class func getDocumentsPath() -> URL? {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return paths.first
    }
    
#if os(iOS) || os(tvOS)
    /// 保存图片到缓存目录下
    ///
    /// - Parameter image: 图片对象
    /// - Returns: [图片名(不包括后缀),图片路径]
    open class func saveImageToAccountRecord(image: UIImage) -> (String?, URL?) {
        var uuid = UUID().uuidString
        uuid = uuid.lowercased()
        
        //        let account = UCPersonalInterface.getMyInfo().m_UserData.m_id.components(separatedBy: "@")[0]
        //        NSString *uuid = [[NSUUID UUID] UUIDString];
        //        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let newImage = image.mm_compressSize()
        
        let data = newImage.jpegData(compressionQuality: 1)
        guard let cachePath = getLocalCachesPath() else {
            MMLOG.error("cachePath获取失败")
            return (nil, nil)
        }
        
        let getPath = cachePath.appendingPathComponent(uuid + ".jpg")
        do {
            try data?.write(to: getPath, options: .atomic)
            //            try data?.write(to: URL(fileURLWithPath: getPath))
            
            //            FileManager.default.createFile(atPath: getPath, contents: data, attributes: nil)
            
        } catch {
            return (nil, nil)
        }
        
        return (uuid,getPath)
    }
    
    //保存图片到缓存
    @discardableResult open class func saveImageToCache(image: UIImage, namePath: String) -> URL? {
        guard let path = getLocalCachesPath() else {
            MMLOG.error("获取cachePath路径失败")
            return nil
        }
        let data = image.pngData()
        
        let getPath = path.appendingPathComponent(namePath + "jpg")
        do {
            try data?.write(to: getPath)
            
        } catch {
            return nil
        }
        
        return getPath
    }
#endif
    //删除缓存图片
    open class func removeImageFromCache(_ imageName: String) {
        guard let cachesPath = getLocalCachesPath() else {
            MMLOG.error("获取cachePath路径失败")
            return
        }
        
        let getPath = cachesPath.appendingPathComponent(imageName + ".jpg")
        if FileManager.default.isDeletableFile(atPath: getPath.path) {
            do {
                try FileManager.default.removeItem(at: getPath)
            } catch {
            }
        }
    }
}
