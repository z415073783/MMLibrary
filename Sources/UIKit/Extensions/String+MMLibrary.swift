//
//  UIImage+Common.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//
#if os(iOS) || os(tvOS)
import Foundation
import UIKit

extension String {
    public func getStringSize(_ font: UIFont) -> CGSize {
        let font: UIFont = font
        let height: CGFloat = font.lineHeight
        let maxRect = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let attributes = [NSAttributedString.Key.font: font as Any]
        let rect: CGRect = self.boundingRect(with: maxRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let textHeight = CGFloat(ceilf(Float(rect.width / CGFloat(mm_kScreenWidth - 24.0)))) * height
        return CGSize(width: rect.width, height: textHeight)
    }

    public func getStringSize(_ font: UIFont, _ maxBorderWidth: CGFloat) -> CGSize {
        let font: UIFont = font
        let height: CGFloat = font.lineHeight
        let maxRect = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let attributes = [NSAttributedString.Key.font: font as Any]
        let rect: CGRect = self.boundingRect(with: maxRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let textHeight = CGFloat(ceilf(Float(rect.width / maxBorderWidth))) * height
        return CGSize(width: rect.width, height: textHeight)
    }

    //部分文字高亮
    public func highLightSubString(subString: String) -> NSMutableAttributedString {
        let range = (self as NSString).range(of: subString)
        let string = NSMutableAttributedString(string: self)
        string.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: range)
        return string
    }


    struct OrderSortModel {
        var range: NSRange?
        var value: Any?
    }

    /// 调整参数顺序 qwe^0$rty^1$uio^2$pas
    ///
    /// - Parameter arguments: 参数可传入String, Double, Int
    /// - Returns:
    public func adjustParamsOrder(arguments: CVarArg...) -> String {
        let dataStr = NSMutableString(string: self)
        let resultList = self.mm_regularExpressionData(pattern: "\\^[0-9]*\\$")
        var sortList: [OrderSortModel] = []
        for result in resultList {
            let range = result.range
            var markStr = dataStr.substring(with: range)
            markStr.removeFirst()
            markStr.removeLast()

            if let markInt = Int(markStr), markInt < arguments.count, let value = arguments[markInt] as? Any  {
                //需要替换的值
                sortList.append(OrderSortModel(range: range, value: value))
            } else {
                MMLOG.error("格式转换错误! markStr = \(markStr); self = \(self)")
            }
        }
        sortList.sort { (first, second) -> Bool in
            guard let location1 = first.range?.location, let location2 = second.range?.location else {
                return true
            }
            return location1 < location2
        }
        for item in sortList.reversed() {
            if let range = item.range {
                var value = item.value as? String
                if value == nil {
                    if let doubleValue = item.value as? Double {
                        value = String(doubleValue)
                    }
                }
                if value == nil {
                    if let intValue = item.value as? Int {
                        value = String(intValue)
                    }
                }

                guard let _value = value else {
                    MMLOG.error("格式转换错误 item.value = \(String(describing: item.value))")
                    continue
                }
                dataStr.replaceCharacters(in: range, with: _value)
            }
            MMLOG.debug("item.range?.location = \(String(describing: item.range?.location))")
        }
        return dataStr as String
        //        String(format: localized("XYearXMonth"), year, month)
    }

}
#endif
