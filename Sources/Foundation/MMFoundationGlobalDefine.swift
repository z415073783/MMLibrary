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
public typealias mm_CallBlockFuncVoid = () -> Void
/// 参数为Any的block回调
public typealias mm_CallBlockFunc = (_ info:Any?) -> Void
/// 参数为Bool的block回调
public typealias mm_CallBlockFuncBool = (_ info: Bool) -> Void
/// 参数为Int的block回调
public typealias mm_CallBlockFuncInt = (_ info: Int) -> Void
/// 参数为Float的block回调
public typealias mm_CallBlockFuncFloat = (_ info: Float) -> Void
/// 参数为Double的block回调
public typealias mm_CallBlockFuncDouble = (_ info: Double) -> Void
/// 参数为String的block回调
public typealias mm_CallBlockFuncString = (_ info: String) -> Void
/// 参数为(String,Int)的block回调
public typealias mm_CallBlockLogLevelString = ( _ info: String, _ type: Int) -> Void
/// 参数为(Int,String)的block回调
public typealias mm_CallBlockFuncIntAndString = (_ type: Int, _ title: String) -> Void
/// 参数为[String]的block回调
public typealias mm_CallBlockFuncStringList = (_ info: [String]) -> Void


// MARK: 字体
/** 默认字体  */
public let mm_kFontTextDefault: String = "Helvetica"
/** 默认加粗字体  */
public let mm_kFontTextDefaultBold: String = "Helvetica-Bold"
/** 默认细体字体  */
public let mm_kFontTextDefaultLight: String = "HelveticaNeue-Light"
// MARK: 字体大小
#if os(iOS) || os(tvOS)
import UIKit
/** 字体大小 10号  */
public let mm_kFontSizeSmallest: CGFloat = 10
/** 字体大小 12号  */
public let mm_kFontSizeSmall: CGFloat = 12
/** 字体大小 14号  */
public let mm_kFontSizeMedium: CGFloat = 14
/** 字体大小 16号  */
public let mm_kFontSizeLarge: CGFloat = 16
/** 字体大小 18号  */
public let mm_kFontSizeLargest: CGFloat = 18
#endif

/** 切换动画时间 0.2秒  */
public let mm_kActionDuration: Double = 0.2
/// 推出动画时间
public let mm_kNavigationPushActionDuration = 0.2

/** 时间常量  */
/** 1 minute  */
public let mm_kIntervalOneMinute: Int = 60 //(60 * 1)
/** 1 hour  */
public let mm_kIntervalOneHour: Int = 3600 //(60 * 60 * 1)
/** 1 day  */
public let mm_kIntervalOneDay: Int = 86400 //(60 * 60 * 24)
/** 1 week  */
public let mm_kIntervalOneWeek: Int = 604800 //(60 * 60 * 24 * 7)
/** 1 month  */
public let mm_kIntervalOneMonth: Int = 2592000 //(60 * 60 * 24 * 30)
/** 1 year  */
public let mm_kIntervalOneYear: Int = 31536000 //(60 * 60 * 24 * 365)

