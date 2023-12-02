//
//  MMLabel.swift
//  Odin-YMS
//
//  Created by zlm on 2017/4/24.
//  Copyright © 2017年 Yealink. All rights reserved.
//

import UIKit

open class MMLabel: UILabel {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        labelDidInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        labelDidInit()
    }
    
    open func labelDidInit() {
        if !Thread.isMainThread {
            MMLOG.error("非主线程初始化UI: \(self)")
        }
//        font = UIFont.fontWithHelvetica(14)
//        textColor = UIColor.black
        textColor = MMColor(red: 0, green: 0, blue: 0)
    }
    
    deinit {
        if !Thread.isMainThread {
            MMLOG.error("非主线程deinit UI: \(self)")
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    private var _touchUpInsideCallback:((_ info:MMLabel?) -> Void)?
    //添加touch手势 block调用
    public func setTouchUpInsideCallBack(block: @escaping (_ info:MMLabel?) -> Void) {
        _touchUpInsideCallback = block
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpInSide(sender:))))
    }
    @objc private func touchUpInSide(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let _touchUpInsideCallback = _touchUpInsideCallback {
                _touchUpInsideCallback(self)
            }
        }
    }

}
