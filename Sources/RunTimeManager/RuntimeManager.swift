//
//  RuntimeManager.swift
//
//  Created by zlm on 2017/11/20.
//  Copyright © 2017年 Yealink. All rights reserved.
//

import Foundation
//实例方法
public func mm_changeInstanceMethod(className: AnyClass, method1: Selector, method2: Selector) {
    let selector = method1
    let my_selector = method2
    guard let originalMethod = class_getInstanceMethod(className, selector) else {
        return
    }
    guard let my_originalMethod = class_getInstanceMethod(className, my_selector) else {
        return
    }
    let didAddMethod = class_addMethod(className, selector, method_getImplementation(my_originalMethod), method_getTypeEncoding(my_originalMethod))
    if didAddMethod {
        class_replaceMethod(className, my_selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, my_originalMethod)
    }
}
//类方法
public func mm_changeClassMethod(className: AnyClass, method1: Selector, method2: Selector) {
    let selector = method1
    let my_selector = method2
    guard let originalMethod = class_getClassMethod(className, selector) else {
        return
    }
    guard let my_originalMethod = class_getClassMethod(className, my_selector) else {
        return
    }
    let didAddMethod = class_addMethod(className, selector, method_getImplementation(my_originalMethod), method_getTypeEncoding(my_originalMethod))
    if didAddMethod {
        class_replaceMethod(className, my_selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, my_originalMethod)
    }
}

public class RuntimeManager: NSObject {
    public static let getInstance = RuntimeManager()
    var preStr = ""

    public class func initSetup() {
        #if DEBUG
//            UIView.changeSelectMethod()
//            //        UIViewController.changeViewControllerMethod()
//            getInstance.keyboardListen()
        #endif
    }
    func keyboardListen() {
//        NotificationCenter.default.mm_addObserver(target: self, name: Notification.Name.keyboardWillShowNotification) { (_) in
////            MMLOG.controlInfo("will open keyboard")
//        }
//        NotificationCenter.default.mm_addObserver(target: self, name: Notification.Name.keyboardWillHideNotification) { (_) in
////            MMLOG.controlInfo("will close keyboard")
//        }
    }
}

