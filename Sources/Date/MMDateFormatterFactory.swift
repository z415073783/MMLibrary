//
//  MMDateFormatterFactory.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

/**
 获取默认DateFormatter
 根据线程分配，单个线程内复用一个DateFormatter，避免多线程串用的情况
 */
public func mm_DateFormatter() -> DateFormatter {
    return MMDateFormatterFactory.getDefatultDateFormatter()
}

/*
 Creating a date formatter is not a cheap operation. If you are likely to use a formatter frequently,
 it is typically more efficient to cache a single instance than to create and dispose of multiple instances.
 One approach is to use a static variable
 
 Apple Document Reference:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
 
 On iOS 7 and later NSDateFormatter is thread safe.
 
 Apple Document Reference:
 https://developer.apple.com/documentation/foundation/dateformatter
 */
public class MMDateFormatterFactory : NSObject {
    public static func getDefatultDateFormatter() -> DateFormatter {
        let curThread = Thread.current
        if let df = curThread.threadDictionary["DefaultDateFormatterKey"] as? DateFormatter {
            return df
        } else {
            let df =  DateFormatter()
            curThread.threadDictionary["DefaultDateFormatterKey"] = df
            return df
        }
    }
}
