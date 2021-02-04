//
//  MMLogModuleManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/2/4.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation

class MMLogArchiveManager {
//    let crashArchiveName = "crash"
//    let defaultArchiveName = "default"
    var lock = NSLock()
    
    static let shared: MMLogArchiveManager = {
        let _shared = MMLogArchiveManager()
//        _shared.setupCrashArchive()
//        _shared.setupDefaultArchive()
        return _shared
    }()
    
//    String: MMLogArchive
    var moduleList: NSMutableDictionary = NSMutableDictionary()
    func set(key: String, archive: MMLogArchive) {
        lock.lock()
        moduleList[key] = archive
        lock.unlock()
    }
    func get(key: String) -> MMLogArchive {
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

    
    func delete(key: String) {
        lock.lock()
        moduleList[key] = nil
        lock.unlock()
    }

    func fireSaveLogs() {
        lock.lock()
        
        _ = moduleList.map { (archive) in
            (archive.value as? MMLogArchive)?.fireSaveLog()
        }
        lock.unlock()
    }
    func writeLogs(log: String) {
        lock.lock()
        _ = moduleList.map { (archive) in
            (archive.value as? MMLogArchive)?.writeFile(log: log)
        }
        lock.unlock()
    }
    func saveLog(archiveName: String, log: String) {
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


