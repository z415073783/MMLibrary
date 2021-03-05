//
//  UILabel+Extension.swift
//  Odin-UC
//
//  Created by zlm on 2017/1/5.
//  Copyright © 2017年 yealing. All rights reserved.
//
#if os(iOS) || os(tvOS)
import UIKit
extension UILabel {
    /// 设置行间距 调用该方法前必须先给label.text赋值
    ///
    /// - Parameter spacing: 间距
    public func setLineSpacing(spacing: Float) {
        let labelText = text ?? ""
        
        let attributeString = NSMutableAttributedString(string: labelText)
        let paragrapthStyle = NSMutableParagraphStyle()
        paragrapthStyle.lineSpacing = CGFloat(spacing)
        attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragrapthStyle], range: NSMakeRange(0, labelText.count))
        attributedText = attributeString
        sizeToFit()
    }

}
#endif
