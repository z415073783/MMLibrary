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
    
    
    struct LoggerDetails {
        public var logLevel: LogLevel
        public var date: Date
        public var logMessage: String
        public var functionName: String
        public var fileName: String
        public var lineNumber: Int
        public init(logLevel: LogLevel, date: Date, logMessage: String, functionName: String, fileName: String, lineNumber: Int) {
            self.logLevel = logLevel
            self.date = date
            self.logMessage = logMessage
            self.functionName = functionName
            self.fileName = fileName
            self.lineNumber = lineNumber
        }
    }
}

public class MMLogger: NSObject {
    public static let logQueueIdentifier = "com.zlm.logger.queue"
    
    let remotePushFilePath: String = NSString.init(format: "%@/Library/Caches/remotePush.log", NSHomeDirectory()) as String
//    public func writeToremotePushLog(log: String) {
//    MMLOG.writeToFile(log: log, remotePushFilePath)
//    }
    
    public var callFunc: mm_CallBlockLogLevelString?
    
    static public let shared = MMLogger()
    //输出方式列表
    public var outputList: [LogOutputType] = [.print, .other]
    
    override init() {
        super.init()
//        self.cleanLogFile(path: logPath)
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
        MMLogger.shared.output(level: .control, text: "\(formattedDate) [Control] \(functionName)> \(logMessage)")
    
    }
    
    
    @objc public class func debug( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Debug, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
        
    }
    
    public class func info( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Info, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func notice( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Notice, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func warning( _ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String=#file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Warning, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func error( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Error, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func crit( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Crit, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func alert( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Alert, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public class func emerg( _ closure:@autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        MMLogger.shared.logln(closure(), logLevel: LogLevel.Emerg, functionName:functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    
    private func logln(_ closure:@autoclosure () -> String?, logLevel: LogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        #if DEBUG
        logln(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        #else
        if logLevel != .Debug {
            logln(logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
        }
        #endif
        
    }
    
    public func logln(logLevel: LogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, closure: () -> String?) {
        if let logMessage = closure() {
            let logDetails: LoggerDetails = LoggerDetails(logLevel: logLevel, date: Date(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
            self.processLogDetails(logDetails: logDetails)
        }
    }
    
    public func processLogDetails(logDetails: LoggerDetails) {
        var extendedDetails: String = ""
        
        #if DEBUG
        var formattedDate: String = logDetails.date.description
        if let dateFormatter = self.dateFormatter {
            formattedDate = dateFormatter.string(from: logDetails.date as Date)
        }
        extendedDetails += "\(formattedDate) "
        #endif
//        extendedDetails += "[APPUI] "
        
        /// 将Module 对应的业务模块信息打入日志作为检查问题模块的方法。
        if logDetails.fileName.contains("Module") {
            let funcPathInfoArray = logDetails.fileName.split(separator: "/")
            for item in funcPathInfoArray {
                if item.contains("Module") && item != "Modules"  && item != "OtherModules" {
                    extendedDetails += "[\(item)]"
                }
            }
        }
        
        extendedDetails += "[\(logDetails.logLevel)] "
        ///根据 file name 中的 Module 然后 归类功能模块
        
        //        if let path:String = logDetails.fileName {
        //
        //            print(path)
        //        }
        
        if Thread.isMainThread {
            extendedDetails += "[main] "
        } else {
            if let threadName: String = Thread.current.name {
                if threadName.count != 0 {
                    extendedDetails += "[" + threadName + "] "
                }
            } else if let queueName = String(cString: DispatchQueue.accessibilityLabel()!, encoding: String.Encoding.utf8) {
                if !queueName.isEmpty {
                    extendedDetails += "[" + queueName + "] "
                }
            } else {
                extendedDetails += "[" + String.init(describing: Thread.current) + "] "
            }
        }
        
        extendedDetails += "[" + (logDetails.fileName as NSString).lastPathComponent + ":" + String(logDetails.lineNumber) + "] "
        
        extendedDetails += "[" + String(logDetails.lineNumber) + "] "
        
        extendedDetails += "\(logDetails.functionName) "
        
        output(level: logDetails.logLevel, text: "\(extendedDetails)> \(logDetails.logMessage)")
        
    }
    open class var LogQueue: DispatchQueue {
        struct Statics {
            static var logQueue = DispatchQueue(label: MMLogger.logQueueIdentifier, attributes: [])
        }
        return Statics.logQueue
    }
    public func output(level: LogLevel, text: String) {
        let outputClosure = {
            let adjustedText = text
            for type in MMLogger.shared.outputList {
                switch type {
                case .print:
                    print("\(adjustedText)")
                case .other:
                    if let block = MMLogger.shared.callFunc {
                        block(adjustedText,level.rawValue)
                    }
                }
            }
            if let block = MMLogger.shared.callFunc {
                block(adjustedText,level.rawValue)
            }
        }
        outputClosure()
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
    
//    let overTimeFilePath: String = NSString.init(format: "%@/Library/Caches/overTime.log", NSHomeDirectory()) as String
//    public func writeToOverTimeLog(log: String) {
//        MMLogger.writeToFile(log: log, overTimeFilePath)
//    }
//
//    public class func writeToFile(log: String, _ path: String? = nil) {
//        #if DEBUG
//        if UIApplication.shared.applicationState == .background {
//            return
//        }
//        let _logPath = path ?? shared.logPath
//        let fileManager = FileManager()
//        let isExist = fileManager.fileExists(atPath: _logPath)
//        if !isExist {
//            fileManager.createFile(atPath: _logPath, contents: Data(base64Encoded: ""), attributes: nil)
//            fileManager.isWritableFile(atPath: _logPath)
//        }
//        do {
//            var logDataFile = try String(contentsOfFile: _logPath)
//            if logDataFile.count > 10000 {
//                //                    logDataFile = logDataFile.substring(to: logDataFile.index(logDataFile.startIndex, offsetBy: 10000))
//                logDataFile = String(logDataFile.prefix(10000))
//            }
//            let logData = logDataFile + log + "<br>"
//
//            try logData.write(toFile: _logPath, atomically: true, encoding: String.Encoding.utf8)
//
//        } catch {
//
//        }
//        #endif
//    }
//
//    public let logPath = NSHomeDirectory() + "/Library/Caches/YLLogger.log"
//
//    public func cleanLogFile(path: String? = nil) {
//        let filePath = path ?? logPath
//        let fileManager = FileManager()
//        do {
//            if fileManager.fileExists(atPath: filePath) {
//                var logData = try String(contentsOfFile: filePath)
//                if logData.count > 100000 {
//                    try fileManager.removeItem(atPath: filePath)
//                } else {
//                    logData = logData + "<br><br><br>"
//                    try logData.write(toFile: filePath,
//                                      atomically: true,
//                                      encoding: String.Encoding.utf8)
//                }
//            }
//        } catch {
//        }
//    }
//
}

