//
//  String+Extension.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif
public extension String {
    
    /// 拼音类型
    ///
    /// - name: 名字
    /// - word: 字母
    /// - firtword: 首字母
    /// - xinAndNameFirstWord: 姓名首字母
    enum MMTransformSpellType {
        case name, word, firtword, xinAndNameFirstWord
    }
    
    /// 中文转拼音
    ///
    /// - Parameter spellType: 拼音类型
    /// - Returns: 拼音字符串
    func mm_transformSpell(spellType: MMTransformSpellType?=MMTransformSpellType.word) -> String {
        let str: CFMutableString = NSMutableString(string:self) as CFMutableString
        var pinyin: String = ""
        if CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false)==true {
            if CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)  == true {
                let pinyinNew: String = str as String
                if spellType == MMTransformSpellType.word {
                    pinyin = pinyinNew.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
                } else if spellType == MMTransformSpellType.name {
                    let spellArr = pinyinNew.components(separatedBy: " ")
                    pinyin = mm_spellCheck(spellArr: spellArr)
                } else if spellType  == MMTransformSpellType.firtword {
                    let spellArr = pinyinNew.components(separatedBy: " ")
                    var firstWord = ""
                    for word in spellArr {
                        let thisword = word as NSString
                        if thisword.length > 1 {
                            firstWord = firstWord + thisword.substring(to: 1)
                        }
                        
                    }
                    pinyin = firstWord
                }  else if spellType  == MMTransformSpellType.xinAndNameFirstWord {
                    var spellArr = pinyinNew.components(separatedBy: " ")
                    if spellArr.count > 0 {
                        if var firstWord = spellArr.first {
                            spellArr.removeFirst()
                            for word in spellArr {
                                let thisword = word as NSString
                                if thisword.length > 1{
                                    firstWord = firstWord + thisword.substring(to: 1)
                                }
                                
                            }
                            pinyin = firstWord
                        }
                    }
                }
            }
        }
        return pinyin
    }
    
    /// 中文转拼音 小写
    ///
    /// - Parameter spellType: 拼音类型
    /// - Returns: 拼音 小写
    func mm_transformSpellWithLowercased(spellType: MMTransformSpellType?=MMTransformSpellType.word) -> String {
        let spell = mm_transformSpell(spellType: spellType)
        return spell.lowercased()
    }
    
    /// 中文转拼音 大写
    ///
    /// - Parameter spellType: 拼音类型
    /// - Returns: 拼音 大写
    func mm_transformSpellWithUppercased(spellType: MMTransformSpellType?=MMTransformSpellType.word) -> String {
        let spell = mm_transformSpell(spellType: spellType)
        return spell.uppercased()
    }
    
    /// 名字拼音纠错检查
    ///
    /// - Parameter spellArr: 拼音
    /// - Returns: 纠正后的拼音字符串 该接口有修改，未验证
    func mm_spellCheck(spellArr: [String]) -> String {
        if self.count == 0 {
            return ""
        }
        var pinyin = ""
        
        let familyName = self[self.startIndex ..< Index(utf16Offset: 1, in: self)]
//        let familyName = self.substring(to: self.index(self.startIndex, offsetBy: 1))
        for i in 0..<spellArr.count {
            var item = spellArr[i]
            if familyName == "曾" && item == "ceng" {
                item = "zeng"
            }
            pinyin = pinyin + item
        }
        return pinyin
    }
    
    #if os(iOS) || os(tvOS)
    
    /// 获取字符串所需的rect
    ///
    /// - Parameters:
    ///   - with: 指定宽度
    ///   - options: 绘制选项
    ///   - attributes: attributes
    ///   - context: 上下文
    /// - Returns: 所需的rect
    public func mm_boundingRect(with: CGSize, options: NSStringDrawingOptions, attributes: [NSAttributedString.Key : Any]?, context: NSStringDrawingContext?) -> CGRect {
        let str: NSString = NSString(string: self)
        return str.boundingRect(with: with, options: options, attributes: attributes, context: context)
    }
    
    
    /// 获取指定宽度字符串自适应高度
    ///
    /// - Parameters:
    ///   - width: 指定宽度
    ///   - font: 字体
    /// - Returns: 自适应高度
    public func mm_getStringHeight(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    /// 获取指定高度字符串自适应宽度
    ///
    /// - Parameters:
    ///   - height: 指定高度
    ///   - font: 字体
    /// - Returns: 自适应宽度
    func mm_getStringWidth(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    #endif
    /// 判断是否有特殊字符
    ///
    /// - Returns: true 是 false 否
    public func mm_hasInAlphabet() -> Bool {
        if !isEmpty {
            let string: NSString = self as NSString
            let c: unichar = string.character(at: 0)
            if islower(Int32(c)) != 0 || isupper(Int32(c)) != 0 {
                return true
            }
        }
        return false
    }
    
    /// 判断字符串是否含有中文，中文符号不包含在内
    ///
    /// - Returns: true 是 false 否
    public func mm_hasChineseWord() -> Bool {
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
    
    /// 从有汉字的字符串中抽取出所有汉字
    ///
    /// - Returns: 抽取出的汉字
    public func mm_getChineseWord() -> String {
        let string: NSString = self as NSString
        var newStr: String = ""
        let count: Int = string.length
        for i in 0 ..< count {
            let a: unichar = string.character(at: i)
            if a > 0x4e00 && a < 0x9fff {
                newStr += String(self[self.index(self.startIndex, offsetBy: i)])
            } else {
                //去掉所有带括号的后半段内容
                let symbol = String(self[self.index(self.startIndex, offsetBy: i)])
                if symbol == "(" || symbol == "（" {
                    break
                }
            }
        }
        return newStr
    }
    
    
    /// 是否为纯数字
    ///
    /// - Returns: true 是 false 否
    public func mm_isNumberText() -> Bool {
        let regex: String = "^[0-9]+$"
        let pred: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isMatch: Bool = pred.evaluate(with: self)
        return isMatch
    }
    
    /// 是否为纯字母
    ///
    /// - Returns: true 是 false 否
    public func mm_isABCCharText() -> Bool {
        let regex: String = "^[a-zA-Z]+$"
        let pred: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isMatch: Bool = pred.evaluate(with: self)
        return isMatch
    }
    
    /// 正则表达式
    ///
    /// - Parameters:
    ///   - pattern: 表达式
    /// - Returns: 结果列表
    public func mm_regularExpressionData(pattern: String) -> [NSTextCheckingResult] {
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
    
    /// 判断是否是ip地址 匹配ipv4,ipv6,域名
    ///
    /// - Returns: true 是 false 否
    public func mm_checkIfIpAddress() -> Bool {
        if self.count == 0 {
            return true
        }
        
        var addressRegex = "^((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)$"
        var result = mm_regularExpressionData(pattern: addressRegex)
        
        if result.count > 0 {
            return true
        }
        
        addressRegex = "^((([0-9a-fA-F]){1,4}:)){7}([0-9a-fA-F]){1,4}$"
        result = mm_regularExpressionData(pattern: addressRegex)
        
        if result.count > 0 {
            return true
        }
        
        addressRegex = "^((http://)|(https://))|(.{1,})"
        result = mm_regularExpressionData(pattern: addressRegex)
        
        if result.count > 0 {
            let list = self.components(separatedBy: ".")
            if list.count > 1 {
                return true
            }
        }
        return false
    }
    
    /// 判断是否是端口
    ///
    /// - Returns: true 是 false 否
    public func mm_checkIfPort() -> Bool {
        if self.count > 0 {
            guard let intSelf = Int(self) else { return false }
            if intSelf >= 0 && intSelf <= 65535 {
                return true
            }
        }
        return false
    }
    
    /// 判断负载均衡值是否正确
    ///
    /// - Returns: true 是 false 否
    public func mm_checkLoad() -> Bool {
        if self.count > 0 {
            guard let intSelf = Int(self) else { return false }
            if intSelf >= 96 && intSelf <= 127 {
                return true
            }
        }
        return false
    }
    
    
    /// 判断是否符合字符限制，不包含!&:;<>[]?%
    ///
    /// - Returns: true 是 false 不是
    func mm_checkSpecialCharacters() -> Bool {
        let specialCharactersSet = CharacterSet(charactersIn: "!&:;<>[]?%")
        
        if let _ = rangeOfCharacter(from: specialCharactersSet) {
            return false
        }
        
        return true
    }
    
    /// 根据给定的分隔符分割字符串
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: 分割的字符串数组
    public func mm_split(_ separator: Character) -> [String] {
        return self.split { $0 == separator }.map(String.init)
    }
}
