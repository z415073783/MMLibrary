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

}
#endif
