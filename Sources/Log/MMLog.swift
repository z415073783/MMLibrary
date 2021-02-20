//
//  MMLog.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2019/5/12.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
public typealias MMLOG = MMLogger


public class MMLogger: NSObject {
    
    public var callFunc: mm_CallBlockLogLevelString?
    
    static public let shared = MMLogger()
    
    //输出方式列表
    public var outputList: [MMLogDefine.LogOutputType] = [.print, .other]
    //日志需要打印的信息类型列表 output Info types ,
    public var outputInfoTypes: [MMLogDefine.LogOutputInfoType] = [.time, .archiveName, .logLevel, .thread, .module, .logPos]
    //module分割字符 文件名带有moduleSplit时会被当做模块名称, 设置该字段后outputInfoTypes的.module的类型才生效
    public var moduleSplit: String?
    //保存日志方式 默认release环境下会保存日志
    public var saveZipConfig: MMLogDefine.LogSaveZipConfig = .save
    //设置日志过滤等级 默认不过滤
    public var filterLevel: MMLogDefine.LogLevel = .none
    
    //release是否打印
//    public var printOfRelease = false
    //是否打印 默认true
//    public var isPrint = true
    
    override init() {
        super.init()
        //崩溃处理
        MMCrashManager.setup()
        //系统通知处理
        MMLogManager.setupListen()
    }
    
    
    @objc public class func logln(logLevel: Int, archiveName: String? = nil, functionName: String, fileName: String, lineNumber: Int, logMessage: String) {
        baseLog(logLevel: MMLogDefine.LogLevel(rawValue: logLevel) ?? .none, archiveName: archiveName, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
    }
    
    public class func none(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
           logln(archiveName: archiveName, closure(), logLevel: .none, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func verbose(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
           logln(archiveName: archiveName, closure(), logLevel: .verbose, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func debug(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .debug, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func control(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .info, functionName:"", fileName: "", lineNumber: 0)
    }
    public class func info(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .info, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func warn(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .warn, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func error(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .error, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func fatal(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .fatal, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func silent(archiveName: String? = nil, _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(archiveName: archiveName, closure(), logLevel: .silent, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    private class func logln(archiveName: String? = nil, _ closure:@autoclosure () -> String?, logLevel: MMLogDefine.LogLevel = .debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {

        if MMLibraryConfig.shared.isDebug {
            if let logMessage = closure() {
                baseLog(logLevel: logLevel, archiveName: archiveName, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
            }
        } else {
            if logLevel != .debug {
                if let logMessage = closure() {
                    baseLog(logLevel: logLevel, archiveName: archiveName, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
                }
            }
        }
    
    }
    private class func baseLog(logLevel: MMLogDefine.LogLevel = .debug, archiveName: String? = nil, functionName: String? = #function, fileName: String = #file, lineNumber: Int = #line, logMessage: String) {
        //判断过滤等级
        if shared.filterLevel.rawValue >= logLevel.rawValue {
            //日志被过滤
            return
        }
    
        var extendedDetails: String = ""
        let outputInfoTypes = MMLogger.shared.outputInfoTypes
        for type in outputInfoTypes {
            switch type {
            case .time:
                extendedDetails += "\(getCurrentTime()) "
            case .archiveName:
                if let _archiveName = archiveName {
                    extendedDetails += "[\(_archiveName)]"
                }
                
            case .logLevel:
                extendedDetails += "[\(logLevel)]"
            case .module:
                /// 将Module 对应的业务模块信息打入日志作为检查问题模块的方法。
                if let moduleSplit = MMLogger.shared.moduleSplit, fileName.contains(moduleSplit) {
                    let funcPathInfoArray = fileName.split(separator: "/")
                    for item in funcPathInfoArray {
                        if item.contains(moduleSplit) {
                            extendedDetails += "[\(item)]"
                        }
                    }
                }
            case .thread:
                if Thread.isMainThread {
                    extendedDetails += "[main]"
                } else {
                    if let threadName: String = Thread.current.name, !threadName.isEmpty {
                        if threadName.count != 0 {
                            extendedDetails += "[\(threadName)]"
                        }
                    } else if let operationName = OperationQueue.current?.name, !operationName.isEmpty {
                        extendedDetails += "[\(operationName)]"
                    } else {
                        let description = Thread.current.description
                        let pre = "number = "
                        let end = ", name"
                        if let startRange = description.range(of: pre), let endRange = description.range(of: end) {
                            let number = String(description[startRange.upperBound ..< endRange.lowerBound])
                            extendedDetails += "[thread \(number)]"
                        } else {
                            extendedDetails += "[\(description)]"
                        }
                    }
                }
            case .logPos:
                extendedDetails += "[\((fileName as NSString).lastPathComponent):\(String(lineNumber))]"
           
            }
        }
        if let functionName = functionName {
            extendedDetails += " \(functionName)"
        }
        
        output(level: logLevel, archiveName: archiveName ?? MMSystem.getAppName(), text: "\(extendedDetails) > \(logMessage)")

    }
    
    private class func output(level: MMLogDefine.LogLevel, archiveName: String, text: String) {
        let outputList = MMLogger.shared.outputList
        let adjustedText = text
        for type in outputList {
            switch type {
            case .print:
//                if shared.isPrint {
//                    print(adjustedText)
//                }
//            #if DEBUG
//                print(adjustedText)
//            #else
//                if shared.printOfRelease {
                print(adjustedText)
//                }
//            #endif
                
            case .other:
                if let block = MMLogger.shared.callFunc {
                    block(adjustedText,level.rawValue)
                }
            }
        }
        MMLogArchiveManager.shared.saveLog(archiveName: archiveName, log: adjustedText)

        
    }

    
    private var _dateFormatter: DateFormatter?
    public var dateFormatter: DateFormatter? {
        get {
            if _dateFormatter != nil {
                return _dateFormatter
            }
            
            let defaultDateFormatter = DateFormatter()
            defaultDateFormatter.locale = NSLocale.current
            defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            _dateFormatter = defaultDateFormatter
            
            return _dateFormatter
        }
        set {
            _dateFormatter = newValue
        }
    }
    
    public class func getCurrentTime() -> String {
        if let dateFormatter = MMLogger.shared.dateFormatter {
            let curDate = Date()
            let curTime = "\(curDate.timeIntervalSince1970)"
            let beginIndex = curTime.index(curTime.endIndex, offsetBy: -3)
            return "\(dateFormatter.string(from: curDate))\(String(curTime[beginIndex..<curTime.endIndex]))"
        }
        return ""
    }
    
}

