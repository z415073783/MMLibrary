//
//  MMLog.swift
//  MMLibrary
//
//  Created by mac on 2019/5/12.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
public typealias MMLOG = MMLogger

public extension MMLogger {
    enum LogLevel: Int {
        case none, verbose, debug, info, warn, error, fatal, silent
        
        public var description: String {
            switch self {
            case .none:
                return "None"
            case .verbose:
                return "Verbose"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .warn:
                return "Warn"
            case .error:
                return "Error"
            case .fatal:
                return "Fatal"
            case .silent:
                return "Silent"
            }
        }
    }
    enum LogOutputType {
        case print, other
    }
    enum LogOutputInfoType {
        case time, logLevel, thread, module, logPos
    }
    enum LogSaveZipConfig {
        case noSave, releaseSave, save
    }
}

public class MMLogger: NSObject {
    
    public var callFunc: mm_CallBlockLogLevelString?
    
    static public let shared = MMLogger()
    //输出方式列表
    public var outputList: [LogOutputType] = [.print, .other]
    //日志需要打印的信息类型列表 output Info types ,
    public var outputInfoTypes: [LogOutputInfoType] = [.time, .logLevel, .thread, .module, .logPos]
    //module分割字符 文件名带有moduleSplit时会被当做模块名称, 设置该字段后outputInfoTypes的.module的类型才生效
    public var moduleSplit: String?
    //保存日志方式 默认release环境下会保存日志
    public var saveZipConfig: LogSaveZipConfig = .save
    //release是否打印
    public var printOfRelease = false
    
    override init() {
        super.init()
    }
    
    
    @objc public class func logln(logLevel: Int, functionName: String, fileName: String, lineNumber: Int, logMessage: String) {
        baseLog(logLevel: LogLevel(rawValue: logLevel) ?? .none, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
    }
    
    public class func none( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
           logln(closure(), logLevel: .none, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func verbose( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
           logln(closure(), logLevel: .verbose, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func debug( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .debug, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func info( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .info, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func warn( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .warn, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func error( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .error, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func fatal( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .fatal, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    public class func silent( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: .silent, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    private class func logln(_ closure:@autoclosure () -> String?, logLevel: LogLevel = .debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
#if DEBUG
        if let logMessage = closure() {
            baseLog(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
        }
#else
        if logLevel != .debug {
            if let logMessage = closure() {
                baseLog(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, logMessage: logMessage)
            }
        }
#endif
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
    
    private class func baseLog(logLevel: LogLevel = .debug, functionName: String? = #function, fileName: String = #file, lineNumber: Int = #line, logMessage: String) {
        var extendedDetails: String = ""
        let outputInfoTypes = MMLogger.shared.outputInfoTypes
        for type in outputInfoTypes {
            switch type {
            case .time:

                extendedDetails += "\(getCurrentTime()) "
            case .logLevel:
                extendedDetails += "[\(logLevel)] "
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
                            extendedDetails += "[main] "
                        } else {
                //            Thread.current
                            if let threadName: String = Thread.current.name, !threadName.isEmpty {
                                if threadName.count != 0 {
                                    extendedDetails += "[\(threadName)] "
                                }
                            } else if let operationName = OperationQueue.current?.name, !operationName.isEmpty {
                                extendedDetails += "[\(operationName)] "
                            } else  if let label = DispatchQueue.accessibilityLabel(), let queueName = String(cString: label, encoding: String.Encoding.utf8), !queueName.isEmpty {
                                extendedDetails += "[\(queueName)] "
                            } else {
                                extendedDetails += "[\(Thread.current.description)] "
                            }
                        }
            case .logPos:
                extendedDetails += "[\((fileName as NSString).lastPathComponent):\(String(lineNumber))] "
            }
        }
        if let functionName = functionName {
            extendedDetails += "\(functionName) "
        }
        output(level: logLevel, text: "\(extendedDetails)> \(logMessage)")
                    
    }
    
    private class func output(level: LogLevel, text: String) {
        let outputList = MMLogger.shared.outputList
        let adjustedText = text
        for type in outputList {
            switch type {
            case .print:
            #if DEBUG
                print(adjustedText)
            #else
                if shared.printOfRelease {
                    print(adjustedText)
                }
            #endif
                
            case .other:
                if let block = MMLogger.shared.callFunc {
                    block(adjustedText,level.rawValue)
                }
            }
        }
        
        switch MMLogger.shared.saveZipConfig {
        case .noSave:
            break
        case .releaseSave:
            #if !DEBUG
            MMLogArchive.saveLog(log: adjustedText)
            #endif
        case .save:
            MMLogArchive.saveLog(log: adjustedText)
        }
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
    
}

