//
//  MMLogModuleManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/2/4.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation

public class MMLogArchiveManager {
//    let crashArchiveName = "crash"
//    let defaultArchiveName = "default"
    var lock = NSLock()
    
    public static let shared: MMLogArchiveManager = {
        let _shared = MMLogArchiveManager()
//        _shared.setupCrashArchive()
//        _shared.setupDefaultArchive()
        return _shared
    }()

    @objc public var rootName = "MMLOG"
    //日志保存的root路径
    public lazy var logRootPath: URL? = {
        //写入数据
        guard let docPath = MMFileData.getDocumentsPath() else {
            print("获取docPath路径失败")
            return nil
        }
        print("docPath = \(docPath)")
        lock.lock()
        let file = docPath.appendingPathComponent(rootName)
        var isDirectory:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory)
        if !isExist {
            do {
                try FileManager.default.createDirectory(at: file, withIntermediateDirectories: true, attributes: nil)
            } catch {
                lock.unlock()
                print("日志文件夹创建失败")
                return nil
            }
        }
        lock.unlock()
        return file
    }()
    
//    String: MMLogArchive
    var moduleList: NSMutableDictionary = NSMutableDictionary()
    public func set(key: String, archive: MMLogArchive) {
        lock.lock()
        moduleList[key] = archive
        lock.unlock()
    }
    public func get(key: String) -> MMLogArchive {
        //如果没有, 则默认添加crash日志路径和default路径
        lock.lock()
        if let archive = moduleList[key] as? MMLogArchive {
            lock.unlock()
            return archive
        }
        lock.unlock()
        let newArchive = MMLogArchive()
        newArchive.identifity = key
        return newArchive
    }

    
    public func delete(key: String) {
        lock.lock()
        moduleList[key] = nil
        lock.unlock()
    }

    public func fireSaveLogs() {
        lock.lock()
        
        _ = moduleList.map { (archive) in
            (archive.value as? MMLogArchive)?.fireSaveLog()
        }
        lock.unlock()
    }
    public func writeLogs(log: String) {
        lock.lock()
        _ = moduleList.map { (archive) in
            (archive.value as? MMLogArchive)?.writeFile(log: log)
        }
        lock.unlock()
    }
    public func saveLog(archiveName: String, log: String) {
        lock.lock()
        var archive = moduleList[archiveName]
        if archive == nil {
            archive = MMLogArchive()
            (archive as? MMLogArchive)?.identifity = archiveName
//            moduleList[archiveName] = archive
        }
        (archive as? MMLogArchive)?.saveLog(log: log)
        moduleList[archiveName] = archive
        lock.unlock()
    }
}


