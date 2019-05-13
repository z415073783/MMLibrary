//
//  MMFileData.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

open class MMFileData: NSObject {
    // MARK: 创建文件夹
    open class func createLocalSupportDicPath(dicName: String) -> Bool {
        let localPath = MMFileData.getLocalSupportPath()
        let createPath = localPath+"/"+dicName
        do {
            try FileManager.default.createDirectory(atPath: createPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
            return false
        }
        return true
    }
    
    // MARK: 创建文件
    open class func createLocalSupportFile(dicName: String, file: String) -> Bool {
        let localPath = MMFileData.getLocalSupportPath()
        let dicPath = localPath+"/"+dicName
        let isExist = FileManager.default.fileExists(atPath: dicName)
        if !isExist {
            let isSuucess = MMFileData.createLocalSupportDicPath(dicName: dicName)
            if !isSuucess {
                MMLOG.error("\(dicPath) create is fail!")
                return false
            }
        }
        let createPath = dicPath+"/"+file
        return FileManager.default.createFile(atPath: createPath, contents: nil, attributes: nil)
    }
    
    // MARK: 读取文件
    open class func readLocalSupportFile(dicName: String, file: String) -> String? {
        let localPath = MMFileData.getLocalSupportPath()
        let writePath = localPath+"/"+dicName+"/"+file
        
        let isExist = FileManager.default.fileExists(atPath: writePath)
        if !isExist {
            return nil
        }
        if let data = FileManager.default.contents(atPath: writePath) {
            let dataStr = String(data: data, encoding: String.Encoding.utf8)
            return dataStr
        }
        
        return nil
    }
    
    // MARK: 写入文件
    open class func writeLocalSupportFile(dicName: String, file: String, data: String) -> Bool {
        let localPath = MMFileData.getLocalSupportPath()
        let writePath = localPath+"/"+dicName+"/"+file
        let isExist = FileManager.default.fileExists(atPath: writePath)
        if !isExist {
            let isSuccess = MMFileData.createLocalSupportFile(dicName: dicName, file: file)
            if !isSuccess {
                MMLOG.error("\(writePath) create is fail!")
                return false
            }
        }
        
        do {
            try data.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            MMLOG.error("\(writePath) write is fail!")
            return false
        }
        return true
    }
    
    // MARK: 获取本地路径
    open class func getLocalLibraryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let localPath = paths[0]
        MMLOG.debug("\(paths)")
        return localPath
    }
    open class func getLocalSupportPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let localPath = paths[0]
        MMLOG.debug("\(paths)")
        return localPath
    }
    open class func getLocalCachesPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let localPath = paths[0]
        MMLOG.debug("\(paths)")
        return localPath
    }
    
    open class func getDocumentsPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        let localPath = paths[0]
        return localPath
    }
    
    /// 保存图片到缓存目录下
    ///
    /// - Parameter image: 图片对象
    /// - Returns: [图片名(不包括后缀),图片路径]
    open class func saveImageToAccountRecord(image: UIImage) -> [String] {
        var uuid = UUID().uuidString
        uuid = uuid.lowercased()
        
        //        let account = UCPersonalInterface.getMyInfo().m_UserData.m_id.components(separatedBy: "@")[0]
        //        NSString *uuid = [[NSUUID UUID] UUIDString];
        //        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let newImage = image.MMcompressSize()
        
        let data = newImage.jpegData(compressionQuality: 1)
        
        let getPath = getLocalCachesPath() + "/" + uuid + ".jpg"
        do {
            try data?.write(to: URL(fileURLWithPath: getPath), options: .atomic)
            //            try data?.write(to: URL(fileURLWithPath: getPath))
            
            //            FileManager.default.createFile(atPath: getPath, contents: data, attributes: nil)
            
        } catch {
            return []
        }
        
        return [uuid,getPath]
    }
    
    //保存图片到缓存
    @discardableResult open class func saveImageToCache(image: UIImage, namePath: String) -> String? {
        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let data = image.pngData()
        
        let getPath = path[0] + "/" + namePath + ".jpg"
        do {
            try data?.write(to: URL(fileURLWithPath: getPath))
            
        } catch {
            return nil
        }
        
        return getPath
    }
    
    //删除缓存图片
    open class func removeImageFromCache(_ imageName: String) {
        let getPath = getLocalCachesPath() + "/" + imageName + ".jpg"
        if FileManager.default.isDeletableFile(atPath: getPath) {
            do {
                try FileManager.default.removeItem(atPath: getPath)
            } catch {
            }
        }
    }
}
