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
        case Emerg = 0
        case Alert
        case Crit
        case Error
        case Warning
        case Notice
        case Info
        case Debug
        case Severe
        case Verbose
        case control
        case None
        
        
        /*  致命级(KERN_EMESG),
         警戒级(KERN_ALERT),
         临界级(KERN_CRIT),
         错误级(KERN_ERR),
         告警级(KERN_WARN),
         注意级(KERN_NOTICE),
         通知级(KERN_INFO),
         调试级(KERN_DEBUG).
         */
        public var description: String {
            switch self {
                
            case .Emerg:
                return "Emerg"
            case .Alert:
                return "Alert"
            case .Crit:
                return "Crit"
            case .Error:
                return "Error"
            case .Warning:
                return "Warning"
            case .Notice:
                return "Notice"
            case .Info:
                return "Info"
            case .Debug:
                return "Debug"
            case .None:
                return "None"
            case .Severe:
                return "Severe"
            case .Verbose:
                return "Verbose"
            case .control:
                return "control"
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
    
    override init() {
        super.init()
    }
    
    /// 专供打印控制信息
    ///
    /// - Parameter closure:
    public class func controlInfo(_ closure: @autoclosure () -> String?, functionName: String = #function) {
        guard let logMessage = closure() else {
            return
        }
        let date = Date()
        var formattedDate: String = date.description
        if let dateFormatter = shared.dateFormatter {
            formattedDate = dateFormatter.string(from: date)
        }
        output(level: .control, text: "\(formattedDate) [Control] \(functionName)> \(logMessage)")
    
    }
    
    
    @objc public class func debug( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        
        logln(closure(), logLevel: LogLevel.Debug, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func info( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Info, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func notice( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Notice, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func warning( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Warning, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func error( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Error, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func crit( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Crit, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func alert( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Alert, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func emerg( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        logln(closure(), logLevel: LogLevel.Emerg, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    private class func logln(_ closure:@autoclosure () -> String?, logLevel: LogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        #if DEBUG
        logln(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #else
        if logLevel != .Debug {
            logln(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        }
        #endif
        
    }
    
    private class func logln(logLevel: LogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, closure: () -> String?) {
        if let logMessage = closure() {
            
            var extendedDetails: String = ""
            let outputInfoTypes = MMLogger.shared.outputInfoTypes
            for type in outputInfoTypes {
                switch type {
                case .time:
                    if let dateFormatter = MMLogger.shared.dateFormatter {
                        extendedDetails += "\(dateFormatter.string(from: Date())) "
                    }
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
                    
                    extendedDetails += "[\(String(lineNumber))] "
                    
                }
            }
            
            extendedDetails += "\(functionName) "
            output(level: logLevel, text: "\(extendedDetails)> \(logMessage)")
            
        }
    }
    
    private class func output(level: LogLevel, text: String) {
        let outputList = MMLogger.shared.outputList
        let adjustedText = text
        for type in outputList {
            switch type {
            case .print:
                print(adjustedText)
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

