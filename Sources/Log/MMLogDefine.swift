//
//  MMLogDefine.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/2/4.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
public class MMLogDefine {
    public enum LogLevel: Int {
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
    public enum LogOutputType {
        case print, other
    }
    public enum LogOutputInfoType {
        case time, archiveName, logLevel, thread, module, logPos
    }
    public enum LogSaveZipConfig {
        case noSave, save
    }
    

    
}
