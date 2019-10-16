//
//  MMDate.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
/// 时间及日期 字符串转换工厂类
open class MMDate: NSObject {
    
    /// 获取当前时间戳
    ///
    /// - Returns: 当前时间戳
    open class func getCurrentTime() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// 标准时间  例:2016年1月1日
    ///
    /// - Returns: 标准时间
    public class func standardTime() -> String {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = "yyyy年MM月dd日"
        let currentDate = Date()
        let currentTime = dateMatter.string(from: currentDate)
        return currentTime
    }
    
    /// 和当前时间相差多少天
    ///
    /// - Parameters:
    ///   - time: 需要判断的时间
    ///   - initDate: 给定初始日期
    /// - Returns: 当前的时间差(单位:天)
    public class func translateTime(_ time: Double, initDate: Date? = nil) -> Int {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        //传入时间
        let date = Date(timeIntervalSince1970: time)
        let getTime = dateMatter.string(from: date)
        let getArr = getTime.components(separatedBy: "-")
        
        //当前时间
        let currentDate = initDate ?? Date()
        let currentTime = dateMatter.string(from: currentDate)
        let currentArr = currentTime.components(separatedBy: "-")
        
        //间隔时间
        var dis = currentDate.timeIntervalSince1970 - time
        
        //计算是否是今天
        var isToday: Bool = true
        for i in 0...2 {
            if getArr[i] != currentArr[i] {
                isToday = false
                break
            }
        }
        if isToday == true {
            //今天
            return 0
        }
        
        
        
        //如果不是今天,那么减去当前时间到凌晨的时间差
        dis -= (Double(currentArr[3]) ?? 0.0) * 60.0 * 60.0
        dis -= (Double(currentArr[4]) ?? 0.0) * 60.0
        dis -= (Double(currentArr[5]) ?? 0.0)
        
        //相隔多少天
        let day = dis/(60*60*24)
        if day < 0 {
            return Int(day)  //大于今天
        }
        return Int(day+1)  //正数是过去,负数是未来
    }
    
    /// 获取传入时间是星期几
    ///
    /// - Parameter time: 传入时间
    /// - Returns: 星期几
    public class func dayOfWeek(time: Double) -> Int {
        let fromDate: Date = Date(timeIntervalSince1970: time)
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let unitFlags: NSCalendar.Unit = NSCalendar.Unit.weekday
        guard let dateComps = calendar?.component(unitFlags, from: fromDate) else { return 0 }
        
        var weekDay = dateComps - 1
        if weekDay == 0 {
            weekDay = 7
        }
        return weekDay
    }
    
    /// 获取传入时间转换为年月日
    ///
    /// - Parameters:
    ///   - timeInterval: 传入时间
    ///   - format: 日期格式，默认为yyyy/MM/dd
    /// - Returns: 获取传入时间转换为年月日
    public class func getYearMonthAndDay(_ timeInterval: TimeInterval, format: String = "yyyy/MM/dd") -> String {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = format
        //传入时间
        let date = Date(timeIntervalSince1970: timeInterval)
        let getTime = dateMatter.string(from: date)
        return getTime
    }
    
    
    //获取传入时间转换为月日
    public class func getMonthAndDay(_ timeInterval: TimeInterval, format: String = "MM/dd") -> String {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = format
        //传入时间
        let date = Date(timeIntervalSince1970: timeInterval)
        let getTime = dateMatter.string(from: date)
        return getTime
    }
    
    //    获取传入时间是哪月
    public class func getMouth(timeInterval: TimeInterval) -> String {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = "yyyy/MM"
        //传入时间
        let date = Date(timeIntervalSince1970: timeInterval)
        let getTime = dateMatter.string(from: date)
        let array  = getTime.components(separatedBy: "/")
        
        let returnTime = array.last
        return returnTime ?? ""
    }
    
    //    获取传入时间是哪年
    public class func getYear(timeInterval: TimeInterval) -> String {
        let dateMatter = mm_DateFormatter()
        dateMatter.dateStyle = DateFormatter.Style.full
        dateMatter.dateFormat = "yyyy"
        //传入时间
        let date = Date(timeIntervalSince1970: timeInterval)
        let getTime = dateMatter.string(from: date)
        return getTime
    }
}
