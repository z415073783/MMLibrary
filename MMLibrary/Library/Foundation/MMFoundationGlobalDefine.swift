//
//  MMFoundationGlobalDefine.swift
//  MMLibrary
//
//  Created by mac on 2019/5/12.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
/// 应用名
public let kDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"]
/// 参数void的block回调
public typealias MMCallBlockFuncVoid = () -> Void
/// 参数为Any的block回调
public typealias MMCallBlockFunc = (_ info:Any?) -> Void
/// 参数为Bool的block回调
public typealias MMCallBlockFuncBool = (_ info: Bool) -> Void
/// 参数为Int的block回调
public typealias MMCallBlockFuncInt = (_ info: Int) -> Void
/// 参数为Float的block回调
public typealias MMCallBlockFuncFloat = (_ info: Float) -> Void
/// 参数为Double的block回调
public typealias MMCallBlockFuncDouble = (_ info: Double) -> Void
/// 参数为String的block回调
public typealias MMCallBlockFuncString = (_ info: String) -> Void
/// 参数为(String,Int)的block回调
public typealias MMCallBlockLogLevelString = ( _ info: String, _ type: Int) -> Void
/// 参数为(Int,String)的block回调
public typealias MMCallBlockFuncIntAndString = (_ type: Int, _ title: String) -> Void
/// 参数为[String]的block回调
public typealias MMCallBlockFuncStringList = (_ info: [String]) -> Void


// MARK: 字体
/** 默认字体  */
public let MMkFontTextDefault: String = "Helvetica"
/** 默认加粗字体  */
public let MMkFontTextDefaultBold: String = "Helvetica-Bold"
/** 默认细体字体  */
public let MMkFontTextDefaultLight: String = "HelveticaNeue-Light"
// MARK: 字体大小
/** 字体大小 10号  */
public let MMkFontSizeSmallest: CGFloat = 10
/** 字体大小 12号  */
public let MMkFontSizeSmall: CGFloat = 12
/** 字体大小 14号  */
public let MMkFontSizeMedium: CGFloat = 14
/** 字体大小 16号  */
public let MMkFontSizeLarge: CGFloat = 16
/** 字体大小 18号  */
public let MMkFontSizeLargest: CGFloat = 18

/** 切换动画时间 0.2秒  */
public let MMkActionDuration: Double = 0.2
/// 推出动画时间
public let MMkNavigationPushActionDuration = 0.2

/** 时间常量  */
/** 1 minute  */
public let MMkIntervalOneMinute: Int = 60 //(60 * 1)
/** 1 hour  */
public let MMkIntervalOneHour: Int = 3600 //(60 * 60 * 1)
/** 1 day  */
public let MMkIntervalOneDay: Int = 86400 //(60 * 60 * 24)
/** 1 week  */
public let MMkIntervalOneWeek: Int = 604800 //(60 * 60 * 24 * 7)
/** 1 month  */
public let MMkIntervalOneMonth: Int = 2592000 //(60 * 60 * 24 * 30)
/** 1 year  */
public let MMkIntervalOneYear: Int = 31536000 //(60 * 60 * 24 * 365)

