//
//  MMSetup.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/10/19.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
import UIKit
public class MMSetup {
    static public let shared = MMSetup()
    class func setup() {
      
        UIView.changeMethod()
        
    }
    
    
    
    
}
extension UIView {
    class func changeMethod() {
        mm_changeInstanceMethod(className: UIView.self, method1: #selector(addSubview(_:)), method2: #selector(_replaceAddSubview(_:)))
    }
    @objc func _replaceAddSubview(_ view: UIView) {
        _replaceAddSubview(view)
        view.mm_loadView()
    }
    /**
     当添加进父类后回调
     */
    @objc open func mm_loadView() {
    }
}

