//
//  MMLogArchive.swift
//  MMLibrary
//
//  Created by zlm on 2020/4/21.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation

@objc public class MMLogArchive: NSObject {
    @objc public static let shared = MMLogArchive()

//MARK: 对外接口
    //单个日志文件size上限
    @objc public var fileMaxSize = 10000000
    //间隔检查日志大小的调用次数上限
    @objc public var callCheckMaxNumber = 1000
    //最大压缩包数量
    @objc public var zipFilesMaxNumber = 5
    @objc public var currentLogName = "current.log"
    @objc public var allZipLogName = "allLog.zip"
    @objc public var rootName = "MMLOG"
    //日志保存接口
    @objc public class func saveLog(log: String) {
        MMLogArchive.shared.writeLock.lock()
        shared.writeFile(log: log)
        MMLogArchive.shared.writeLock.unlock()
    }
    @objc public class func getLogZipPath() -> URL? {
        return shared.currentLogFile?.deletingLastPathComponent().appendingPathComponent(shared.allZipLogName)
    }
    
    //    将所有日志打包成压缩文件
    @objc public class func getAllLogZip() -> String {
        
        guard let zipPath = getLogZipPath() else {
            return ""
        }
        let rootPath = zipPath.deletingLastPathComponent()
//
//        let zipPath = rootPath.appendingPathComponent(shared.allZipLogName)
        do {
            //移除原有日志文件
            try shared.filemanager.removeItem(at: zipPath)
        } catch  {
            print("移除失败 error = \(error)")
        }
       
        let zipLogFiles = MMFileData.searchFilePath(rootPath: rootPath.path, selectFile: ".zip", isSuffix: true, onlyOne: false)
        let logFiles = MMFileData.searchFilePath(rootPath: rootPath.path, selectFile: ".log", isSuffix: true, onlyOne: false)
        var goalPaths: [URL] = []
        for logItem in zipLogFiles {
            goalPaths.append(URL(fileURLWithPath: logItem.fullPath()))
        }
        for logItem in logFiles {
            goalPaths.append(URL(fileURLWithPath: logItem.fullPath()))
        }

        
        do {
            //移除原有日志文件
            if shared.filemanager.fileExists(atPath: zipPath.path) {
                try shared.filemanager.removeItem(at: zipPath)
            }
            
            print("goalPaths = \(goalPaths), zipPath = \(zipPath)")
            //压缩
            try MMZip.zipFiles(paths: goalPaths, zipFilePath: zipPath, password: nil, progress: nil)
        } catch  {
            print("操作失败 error = \(error)")
        }
        
       
        return zipPath.path
    }
    
//MARK: 私有变量
    let zipQueue: MMOperationQueue = MMOperationQueue(maxCount: 1)
    let filemanager = FileManager.default
    let writeLock = NSLock()
    var callCheckNumber = 0
    var currentHandler: FileHandle?
    
    lazy var logFolderPath: URL? = {
        //写入数据
        guard let docPath = MMFileData.getDocumentsPath() else {
            print("获取docPath路径失败")
            return nil
        }
        
        let file = docPath.appendingPathComponent(MMLogArchive.shared.rootName)
        var isDirectory:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory)
        if !isExist {
            do {
                try FileManager.default.createDirectory(at: file, withIntermediateDirectories: true, attributes: nil)

            } catch {
                print("日志文件夹创建失败")
                return nil
            }
        }
        
        return file
    }()
    lazy var currentLogFile: URL? = {
        guard let logFolderPath = self.logFolderPath else {
            return nil
        }
        let file = logFolderPath.appendingPathComponent(currentLogName)
        return file
    }()

}
fileprivate typealias _Private = MMLogArchive
extension _Private {
    //检查并创建currentLog文件
        func checkCurrentLogFile() -> Bool {
            guard let currentLogFile = currentLogFile else {
                return false
            }
            var isExist = filemanager.fileExists(atPath: currentLogFile.path)
            if !isExist {
                isExist = filemanager.createFile(atPath: currentLogFile.path, contents: Data(), attributes: nil)
            }
            if isExist {
                return true
            }
            return false
        }
        //将日志文件转存成zip
        func archiveLogToZip(path: URL, name: String) {
            zipQueue.addOperation { [weak self] in
                guard let `self` = self else {
                    return
                }
                let logRootPath = path.deletingLastPathComponent()
                let zipPath = logRootPath.appendingPathComponent(name + ".zip")
                print("保存日志压缩文件 = \(zipPath)")
                do {
                    //压缩
                    try MMZip.zipFiles(paths: [path], zipFilePath: zipPath, password: nil, progress: nil)
                    
                    //移除原有日志文件
                    try self.filemanager.removeItem(at: path)
                    
                    //检查压缩包数量并删除上限
                    self.checkAndRemoveMoreTheNumberOfZip(rootPath: logRootPath)
                    
                    
                } catch {
                    print("压缩失败 zipPath = \(zipPath)")
                }
            }
        }
        
        func checkAndRemoveMoreTheNumberOfZip(rootPath: URL) {
    //        print("rootPath.path = \(rootPath.path)")
            var allLogFiles: [ProjectPathModel] = []
            let zipFiles = MMFileData.searchFilePath(rootPath: rootPath.path, selectFile: ".zip", isSuffix: true, onlyOne: false)
            let logFiles = MMFileData.searchFilePath(rootPath: rootPath.path, selectFile: ".log", isSuffix: true, onlyOne: false)
            for zipItem in zipFiles {
                if zipItem.name != allZipLogName {
                    allLogFiles.append(zipItem)
                }
            }
            
            for logItem in logFiles {
                if logItem.name != MMLogArchive.shared.currentLogName {
                    allLogFiles.append(logItem)
                }
            }
            if allLogFiles.count <= zipFilesMaxNumber {
                return
            }

            do {
                var oldTime: TimeInterval = 0
                var oldFilePath: String = ""
                for i in 0 ..< allLogFiles.count {
                    let item = allLogFiles[i]
                   
                    let attribute = try filemanager.attributesOfItem(atPath: item.fullPath())
                    if let date = attribute[FileAttributeKey.creationDate] as? Date {
                        let curTime = date.timeIntervalSince1970
                        if i == 0 {
                            oldTime = curTime
                            oldFilePath = item.fullPath()
                        } else if oldTime > curTime {
                            oldTime = curTime
                            oldFilePath = item.fullPath()
                        }
                    }
                }
              
                if oldFilePath.count > 0 {
                    //删除
                    try filemanager.removeItem(atPath: oldFilePath)
                    checkAndRemoveMoreTheNumberOfZip(rootPath: rootPath)
                } else {
                    print("操作失败, 未获取到文件路径 allLogFiles = \(allLogFiles)")
                    return
                }
                
            } catch {
                print("操作失败: error = \(error)")
            }

        }
        
    
    func checkSizeAndSaveZip() {
        if callCheckNumber == 0 {
            //检查currentLog是否存在, 不存在则创建
            let _ = self.checkCurrentLogFile()
            
            guard let currentLogFile = self.currentLogFile else {
                return
            }
            do {
                currentHandler = try FileHandle(forWritingTo: currentLogFile)
            } catch {
                print("文件读取失败 currentLogFile = \(currentLogFile)")
                
                return
            }
        }
        
        //做间隔检查
        callCheckNumber += 1
        if callCheckNumber < callCheckMaxNumber {
            return
        }
        callCheckNumber = 0
        
        guard let currentLogFile = currentLogFile else {
            return
        }
        do {
            let attribute = try filemanager.attributesOfItem(atPath: currentLogFile.path)
            guard let fileSize = (attribute[FileAttributeKey.size] ?? "0") as? Int else {
                return
            }
            //如果小于文件大小小于最大上限,则不处理
            if fileSize < fileMaxSize {
                return
            }
            let timeName = String(format: "\(attribute[FileAttributeKey.creationDate] ?? "")")
            let fileCreateTime = timeName + ".log"
            //文件移动
            let newLogFile = currentLogFile.deletingLastPathComponent().appendingPathComponent(fileCreateTime)
            do {
                try filemanager.moveItem(at: currentLogFile, to: newLogFile)
            } catch {
                print("移动currentLogFile:\(currentLogFile) -> newLogFile:\(newLogFile) 失败")
            }
            
            archiveLogToZip(path: newLogFile, name: timeName)

            //重新运行该方法, 保证currentLog创建流程正常
            checkSizeAndSaveZip()
            
        } catch {
            print("获取log文件属性失败")
        }
    }
    
    func writeFile(log: String) {

        //检查文件大小, 如果过大就进入异步做压缩保存,并重新生成log文件
        self.checkSizeAndSaveZip()
        guard let _handler = self.currentHandler else {
            return
        }
        
        let _item = log + "\n"
        if let appendData = _item.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            _handler.seekToEndOfFile()
            _handler.write(appendData)
        }
    }
    

    
    
}
