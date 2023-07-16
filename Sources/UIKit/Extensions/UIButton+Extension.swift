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
public extension UIButton {
    /**
     通过手势点击(规避navigationbar上的按钮响应延迟问题)
     
     - parameter target: target
     - parameter action: action
     */
    func mm_addtarget(_ target: AnyObject?, action: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
    }

    /// 设置背景色
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - state: 需要设置的状态
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.mm_imageWithColor(color: color), for: state)
    }
    
    func zlm_setImage(image: UIImage?) {
        if #available(iOS 15.0, *) {
            zlm_configuration { config in
                config.image = image
            }
            
        } else {
            setImage(image, for: .normal)
        }
    }
    func zlm_setImageTrailingPadding(padding: CGFloat) {
        if #available(iOS 15.0, *) {
            zlm_configuration { config in
                config.imagePadding = padding
                config.imagePlacement = .trailing
            }
        } else {
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
        }
    }
    
    func zlm_setTitleConfig(title: String, color: UIColor, font: UIFont) {
        if #available(iOS 15.0, *) {
            zlm_configuration { config in
                config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: font, .foregroundColor: color]))
//                config.titleLineBreakMode = .byClipping
//                config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            }
        } else {
            MMAssert.fire("未实现")
        }
    }
}

@available(iOS 15.0, *)
public extension UIButton {
    func zlm_configuration(execute:((_ config: inout UIButton.Configuration) -> Void)) {
        if var existConfig = self.configuration  {
            execute(&existConfig)
            self.configuration = existConfig
        } else {
            var config = UIButton.Configuration.plain()
            execute(&config)
            self.configuration = config
        }
    }
}

#endif
