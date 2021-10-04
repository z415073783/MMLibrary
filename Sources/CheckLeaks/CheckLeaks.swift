//
//  CheckLeaks.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/2/26.
//  Copyright © 2021 zlm. All rights reserved.
//
//内存泄漏检查(只在debug模式下检查) -> 在pop和dismiss方法中,添加即将被释放的视图(包括子视图和子属性,需要递归检查)的weak引用, 在延迟后检查weak的对象是否还存在,如果对象存在则说明未被释放(需要过滤单例)

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
class CheckLeaks {
    
    func setup() {
        
//        mm_changeInstanceMethod(className: <#T##AnyClass#>, method1: <#T##Selector#>, method2: <#T##Selector#>)
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}

extension UIViewController {
//    open func mm_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//        self.mm_present(viewControllerToPresent, animated: flag, completion: completion)
//        
//        
//        
//        
//        
//        
//    }
//    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        MMLOG.info("123123")
//
//
//
//    }
//
//    open func mm_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        self.mm_dismiss(animated: flag, completion: completion)
//
//
//
//    }
    
    
    
}

extension UINavigationController {
    
}






#endif
