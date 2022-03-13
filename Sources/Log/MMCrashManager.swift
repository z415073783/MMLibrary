//
//  MMCrashManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/5/8.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation

//fileprivate var _uncaughtExceptionMaximum = 10
var _getSignDic: [Int32: Bool] = [:]

fileprivate func _crashSignCall(sign: Int32) {
    if _getSignDic[sign] != nil  {
        return
    }
    _getSignDic[sign] = true
    MMLOG.fatal("sign = \(sign)")
    _saveCrash()
}
fileprivate var _caughtExceptionCallNum = 0
fileprivate func _uncaughtExceptionCall(exception: NSException) {
    _saveCrash(exception: exception)
}

fileprivate func _saveCrash(exception: NSException? = nil) {
    MMLogArchiveManager.shared.fireSaveLogs()
    
    if _caughtExceptionCallNum >= 1 {
        return
    }
    _caughtExceptionCallNum += 1
    
    var crashContainer = ""
    
    crashContainer += "crash:\n"
    if let exception = exception {
        crashContainer += "\nexception.callStackSymbols:\n"
        for item in exception.callStackSymbols {
            crashContainer += "\(item)\n"
        }
    }
    
    crashContainer += "\nThread.callStackSymbols:\n"
    for item in Thread.callStackSymbols {
        crashContainer += "\(item)\n"
    }
    
    //日志路径:
    
    
    guard let rootPath = MMLogArchiveManager.shared.get(key: "Crash").logFolderPath else {
        return
    }
    //写入crash文件
    do {
        try "\(MMLogger.getCurrentTime())\n\(crashContainer)".write(to: rootPath.appendingPathComponent(MMCrashManager.shared.crashName), atomically: true, encoding: String.Encoding.utf8)
    } catch {
        MMLOG.fatal("error = \(error)")
    }
    //写入日志文件
    MMLOG.fatal(crashContainer)
    MMLogArchiveManager.shared.fireSaveLogs()
}

public class MMCrashManager: NSObject {
    public static let shared = MMCrashManager()
    public var crashName = "exception.crash"
    //调用该函数注册crash收集
    public class func setup() {
//        MMLOG.debug("crash文件保存路径 = \(MMLogArchive.shared.logFolderPath?.path ?? "")")
        NSSetUncaughtExceptionHandler(_uncaughtExceptionCall(exception:))
        signal(SIGABRT, _crashSignCall(sign:))
        signal(SIGILL, _crashSignCall(sign:))
        signal(SIGSEGV, _crashSignCall(sign:))
        signal(SIGFPE, _crashSignCall(sign:))
        signal(SIGBUS, _crashSignCall(sign:))
        signal(SIGPIPE, _crashSignCall(sign:))
    }
 
}
