//
//  String+Regular.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/4/12.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
public extension String {
    func split(_ separator: Character) -> [String] {
        return self.split { $0 == separator }.map(String.init)
    }
    /// 正则表达式查询
    ///
    /// - Parameters:
    ///   - pattern: 表达式
    /// - Returns: 结果列表
    func regularExpressionFind(pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)

            /// 在string中有emoji时，text.count在regex中的字符数不一致，text.utf16.count
            let textRange = NSRange(self.startIndex..., in: self)
            let res = regex.matches(in: self,
                                    options: .reportProgress,
                                    range: textRange)
            return res
        } catch {
            return []
        }
    }

    //使用正则表达式替换
    func regularExpressionReplace(pattern: String, with: String,
                                  options: NSRegularExpression.Options = []) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return regex.stringByReplacingMatches(in: self, options: [],
                                                  range: NSMakeRange(0, self.count),
                                                  withTemplate: with)
        } catch {
            MMLOG.error("正则表达式替换失败 pattern = \(pattern); with = \(with); self = \(self); error = \(error)")
            return nil
        }
    }

    /// 判断字符串是否含有中文，中文符号不包含在内
    ///
    /// - Returns: true 是 false 否
    func hasChineseWord() -> Bool {
        let string: NSString = self as NSString
        let count: Int = string.length
        for i in 0 ..< count {
            let a: unichar = string.character(at: i)
            if a > 0x4e00 && a < 0x9fff {
                return true
            }
        }
        return false
    }
    
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
     *去掉首尾空格 后 指定开头空格数
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }

}
