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

public enum MMFileDataUserFilePathType {
    case document, cache
}
public enum MMFileDataSaveImageType {
    case png, jpg
}

open class MMFileData: NSObject {
    // MARK: 创建文件夹
    open class func createDocumentFolder(dicName: String, rootURL: URL? = MMFileData.getDocumentsPath()) -> Bool {
        guard let localPath = rootURL else {
            MMLOG.error("获取rootURL失败")
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
    open class func createDocumentFile(dicName: String, file: String) -> Bool {
        guard let localPath = MMFileData.getDocumentsPath() else {
            MMLOG.error("获取supportPath失败")
            return false
        }
        let dicPath = localPath.appendingPathComponent(dicName)
        let isExist = FileManager.default.fileExists(atPath: dicPath.path)
        if !isExist {
            let isSuucess = MMFileData.createDocumentFolder(dicName: dicName)
            if !isSuucess {
                MMLOG.error("\(dicPath) create is fail!")
                return false
            }
        }
        let createPath = dicPath.appendingPathComponent(file)
        return FileManager.default.createFile(atPath: createPath.path, contents: nil, attributes: nil)
    }
    
    // MARK: 读取文件
    open class func readDocumentFile(dicName: String, file: String) -> String? {
        guard let localPath = MMFileData.getDocumentsPath() else {
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
    open class func writeDocumentFile(dicName: String, file: String, data: String) -> Bool {
        guard let localPath = MMFileData.getDocumentsPath() else {
            MMLOG.error("获取supportPath失败")
            return false
        }
        let writePath = localPath.appendingPathComponent(dicName).appendingPathComponent(file)
        let isExist = FileManager.default.fileExists(atPath: writePath.path)
        if !isExist {
            let isSuccess = MMFileData.createDocumentFile(dicName: dicName, file: file)
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
    
    //获取group中的共享路径
    open class func getApplicationGroupPath(identifity: String) ->URL? {
//        MMLOG.debug("identifityURL = \(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifity))")
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifity)
        return path
    }
    
    

    /// 保存图片到缓存目录下
    ///
    /// - Parameter image: 图片对象
    /// - Returns: [图片名(不包括后缀),图片路径]
//    open class func saveImageToAccountRecord(image: UIImage) -> (String?, URL?) {
//        var uuid = UUID().uuidString
//        uuid = uuid.lowercased()
//
//        //        let account = UCPersonalInterface.getMyInfo().m_UserData.m_id.components(separatedBy: "@")[0]
//        //        NSString *uuid = [[NSUUID UUID] UUIDString];
//        //        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        let newImage = image.mm_compressSize()
//
//        let data = newImage.jpegData(compressionQuality: 1)
//        guard let cachePath = getLocalCachesPath() else {
//            MMLOG.error("cachePath获取失败")
//            return (nil, nil)
//        }
//
//        let getPath = cachePath.appendingPathComponent(uuid + ".jpg")
//        do {
//            try data?.write(to: getPath, options: .atomic)
//            //            try data?.write(to: URL(fileURLWithPath: getPath))
//
//            //            FileManager.default.createFile(atPath: getPath, contents: data, attributes: nil)
//
//        } catch {
//            return (nil, nil)
//        }
//
//        return (uuid,getPath)
//    }
//
    //保存图片到缓存 自定义名字
//    @discardableResult open class func saveImageToCache(image: UIImage, namePath: String) -> URL? {
//        guard let path = getLocalCachesPath() else {
//            MMLOG.error("获取cachePath路径失败")
//            return nil
//        }
//        let data = image.pngData()
//
//        let getPath = path.appendingPathComponent(namePath + "jpg")
//        do {
//            try data?.write(to: getPath)
//
//        } catch {
//            return nil
//        }
//
//        return getPath
//    }

    //获取图片缓存路径
    open class func getImageSavePath(type: MMFileDataUserFilePathType) -> URL? {
        var _savePath: URL?
        if type == .cache {
            _savePath = getLocalCachesPath()
        } else if type == .document {
            _savePath = getDocumentsPath()
        }
        guard var savePath = _savePath else {
            return nil
        }
        savePath.appendPathComponent("image")
        
        if !FileManager.default.fileExists(atPath: savePath.path) {
            do {
                try FileManager.default.createDirectory(at: savePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                MMLOG.error("文件夹创建失败")
                return nil
            }
        }
        
        return savePath
    }
#if os(iOS) || os(tvOS)
//保存图片到指定路径 名字可为nil,不带后缀
    open class func saveImageToPath(image: UIImage, name: String? = nil, path: URL?, imageType: MMFileDataSaveImageType) ->(String?, URL?) {
        var _newName = name
        if _newName == nil {
            var uuid =  UUID().uuidString
            uuid = uuid.lowercased()
            _newName = uuid
        }

        let newImage = image.mm_compressSize()
        var data: Data?
        if imageType == .jpg {
            data = newImage.jpegData(compressionQuality: 1)
        } else if imageType == .png {
            data = newImage.pngData()
        }
        
        guard let savePath = path, let newName = _newName else {
            return (nil, nil)
        }

        //根据当前分辨率设置图片@2x or @3x格式
//        UIScreen.main.currentMode?.size
//        UIScreen.main.bounds
        let currentModelW = UIScreen.main.currentMode?.size.width ?? UIScreen.main.bounds.size.width
        let scale = Int(currentModelW / UIScreen.main.bounds.size.width)
        let getPath = savePath.appendingPathComponent(newName + "@\(scale)x" + (imageType == .jpg ? ".jpg" : ".png"))
        
        if FileManager.default.fileExists(atPath: getPath.path) {
            //删除同名缓存文件
            if FileManager.default.isDeletableFile(atPath: getPath.path) {
                do {
                    try FileManager.default.removeItem(at: getPath)
                } catch {
                    MMLOG.error("删除失败 error = \(error)")
                }
            }
        }
        
        do {
            MMLOG.debug("getPath = \(getPath)")
            try data?.write(to: getPath, options: .atomic)
        } catch {
            MMLOG.error("写入失败 error = \(error)")
            return (nil, nil)
        }
        
        return (newName,getPath)
    }


    //保存图片到沙盒 名字可为nil,不带后缀
    open class func saveImageToSanBox(image: UIImage, name: String? = nil, type: MMFileDataUserFilePathType, imageType: MMFileDataSaveImageType) ->(String?, URL?) {
        return saveImageToPath(image: image, name: name, path: getImageSavePath(type: type), imageType: imageType)
    }


#endif
    //删除缓存图片
    open class func removeImageFromCache(_ imageName: String) {
        guard let cachesPath = getImageSavePath(type: .cache) else {
            MMLOG.error("获取cachePath路径失败")
            return
        }
        
        let getPath = cachesPath.appendingPathComponent(imageName + ".jpg")
        if FileManager.default.isDeletableFile(atPath: getPath.path) {
            do {
                try FileManager.default.removeItem(at: getPath)
                return
            } catch {
            }
        }
        let getPngPath = cachesPath.appendingPathComponent(imageName + ".png")
        if FileManager.default.isDeletableFile(atPath: getPngPath.path) {
            do {
                try FileManager.default.removeItem(at: getPngPath)
                return
            } catch {
            }
        }
    }
}
