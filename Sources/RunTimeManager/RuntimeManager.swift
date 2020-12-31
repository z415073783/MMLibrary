//
//  RuntimeManager.swift
//
//  Created by zlm on 2017/11/20.
//  Copyright © 2017年 Yealink. All rights reserved.
//

import Foundation

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

// MARK: - UIButton
extension UIControl {
//    @objc func my_sendAction(action: Selector, to target: AnyObject?, forEvent event: UIEvent?) {
////        MMLOG.controlInfo("from:\(String(describing: target?.description))\nButton:\(self.description)")
//        my_sendAction(action: action, to: target, forEvent: event)
//    }
//    class func changeMethod() {
//        mm_changeInstanceMethod(className: classForCoder(), method1: #selector(UIControl.sendAction(_:to:for:)), method2: #selector(UIControl.my_sendAction(action:to:forEvent:)))
//    }
}

extension UIScrollView {
//    class func changeTouchMethod() {
//        mm_changeInstanceMethod(className: classForCoder(), method1: #selector(UIScrollView.touchesBegan(_:with:)), method2: #selector(UIScrollView.my_touchesBegan(_:with:)))
//        mm_changeInstanceMethod(className: classForCoder(), method1: #selector(UIScrollView.touchesMoved(_:with:)), method2: #selector(UIScrollView.my_touchesMoved(_:with:)))
//        mm_changeInstanceMethod(className: classForCoder(), method1: #selector(UIScrollView.touchesEnded(_:with:)), method2: #selector(UIScrollView.my_touchesEnded(_:with:)))
//        mm_changeInstanceMethod(className: classForCoder(), method1: #selector(UIScrollView.touchesCancelled(_:with:)), method2: #selector(UIScrollView.my_touchesCancelled(_:with:)))
//    }
//
//    @objc open func my_touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        my_touchesBegan(touches, with: event)
//    }
//    @objc open func my_touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        my_touchesMoved(touches, with: event)
//    }
//
//    @objc open func my_touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        my_touchesEnded(touches, with: event)
//    }
//
//    @objc open func my_touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
////        MMLOG.controlInfo("touch Cancelled: \(String(describing: self.description))\nself.className() = \(self.className())")
//        my_touchesCancelled(touches, with: event)
//    }
}

extension UIViewController {
//    class func changeViewControllerMethod() {
//        mm_changeInstanceMethod(className: UIViewController.classForCoder(), method1: #selector(UIViewController.viewDidLoad), method2: #selector(UIViewController.my_viewDidLoad))
//        mm_changeInstanceMethod(className: UIViewController.classForCoder(), method1: #selector(UIViewController.viewDidAppear(_:)), method2: #selector(UIViewController.my_viewDidAppear(_:)))
//        mm_changeInstanceMethod(className: UIViewController.classForCoder(), method1: #selector(UIViewController.viewDidDisappear(_:)), method2: #selector(UIViewController.my_viewDidDisappear(_:)))
//    }
//
//    @objc open func my_viewDidLoad() {
////        MMLOG.controlInfo(" \(self.description)")
//        my_viewDidLoad()
//    }
//    @objc open func my_viewDidAppear(_ animated: Bool) {
////        MMLOG.controlInfo(" \(self.description)")
//        my_viewDidAppear(animated)
//    }
//    @objc open func my_viewDidDisappear(_ animated: Bool) {
////        MMLOG.controlInfo(" \(self.description)")
//        my_viewDidDisappear(animated)
//    }
}

extension UIView {
//    class func changeSelectMethod() {
//
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:)), method2: #selector(UIView.my_perform(_:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:with:)), method2: #selector(UIView.my_perform(_:with:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:with:with:)), method2: #selector(UIView.my_perform(_:with:with:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:with:afterDelay:)), method2: #selector(UIView.my_perform(_:with:afterDelay:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:on:with:waitUntilDone:)), method2: #selector(UIView.my_perform(_:on:with:waitUntilDone:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:with:afterDelay:inModes:)), method2: #selector(UIView.my_perform(_:with:afterDelay:inModes:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.performSelector(inBackground:with:)), method2: #selector(UIView.my_performSelector(inBackground:with:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.perform(_:on:with:waitUntilDone:modes:)), method2: #selector(UIView.my_perform(_:on:with:waitUntilDone:modes:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.performSelector(onMainThread:with:waitUntilDone:)), method2: #selector(UIView.my_performSelector(onMainThread:with:waitUntilDone:)))
//        mm_changeInstanceMethod(className: UIView.classForCoder(), method1: #selector(UIView.performSelector(onMainThread:with:waitUntilDone:modes:)), method2: #selector(UIView.my_performSelector(onMainThread:with:waitUntilDone:modes:)))
//
//    }
//
//    func checkUselessKey(sender: String) -> Bool {
//        switch sender {
//        case "_subscribeToScrollNotificationsIfNecessary:",
//             "_unsubscribeToScrollNotificationsIfNecessary:",
//             "_sendDeferredCompletion:",
//             "_sendDeferredCompletion:",
//             "privateHandlePickableRoutesChange",
//             "_willMoveToWindow:",
//             "_willBeginBlockAnimation:context:",
//             "_willMoveToWindow:withAncestorView:",
//             "_clearMouseView",
//             "handleVOIPServiceStandByNotification:",
//             "workWithEvent:",
//             "connect",
//             "jce_list",
//             "removeFromSuperlayer",
//             "renderEdgeEffect:withTraits:",
//             "tooSlow: NSObject":
//            return true
//        default:
//            return false
//        }
//    }
//    func checkUserlessAnchorKey(sender: String) -> Bool {
//        if sender.hasSuffix("Anchor") {
//            return true
//        }
//        return false
//    }
//    func checkUserlessLayoutSublayersOfLayerKey(sender: String) -> Bool {
//        if sender.hasPrefix("layoutSublayersOfLayer") {
//            return true
//        }
//        return false
//    }
//    func checkData(sender: String) {
//
//        //过滤Anchor关键字
//        if checkUserlessAnchorKey(sender: sender) {
//            return
//        }
//        //过滤LayoutSublayersOfLayer关键字
//        if checkUserlessLayoutSublayersOfLayerKey(sender: sender) {
//            return
//        }
//        // 过滤无效关键字
//        if checkUselessKey(sender: sender) {
//            return
//        }
//        if RuntimeManager.getInstance.preStr == sender {
//            return
//        }
//        RuntimeManager.getInstance.preStr = sender
//        if let superView = self.superview {
////            MMLOG.controlInfo("method selector: \(sender), self: =\(self.description), superView:\(String(describing: superView.className()))", functionName: "")
//        } else {
////            MMLOG.controlInfo("method selector: \(sender), self: =\(self.description)", functionName: "")
//        }
//    }
//    @objc public func my_perform(_ aSelector: Selector) -> Unmanaged<AnyObject> {
//
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector)
//    }
//
//    @objc public func my_perform(_ aSelector: Selector, with object: Any) -> Unmanaged<AnyObject> {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector, with: object)
//    }
//
//    @objc public func my_perform(_ aSelector: Selector, with object1: Any, with object2: Any) -> Unmanaged<AnyObject> {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector, with: object1, with: object2)
//    }
//    @objc open func my_perform(_ aSelector: Selector, with anArgument: Any?, afterDelay delay: TimeInterval, inModes modes: [RunLoopMode]) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//         return my_perform(aSelector, with: anArgument, afterDelay: delay, inModes: modes)
//    }
//
//    @objc open func my_perform(_ aSelector: Selector, with anArgument: Any?, afterDelay delay: TimeInterval) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector, with: anArgument, afterDelay: delay)
//    }
//    @objc open func my_performSelector(onMainThread aSelector: Selector, with arg: Any?, waitUntilDone wait: Bool, modes array: [String]?) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_performSelector(onMainThread: aSelector, with: arg, waitUntilDone: wait, modes: array)
//    }
//
//    @objc open func my_performSelector(onMainThread aSelector: Selector, with arg: Any?, waitUntilDone wait: Bool) {
//        let selectorDes = String(aSelector.description)
//       checkData(sender: selectorDes)
//        return my_performSelector(onMainThread: aSelector, with: arg, waitUntilDone: wait)
//    }
//
//    @objc open func my_perform(_ aSelector: Selector, on thr: Thread, with arg: Any?, waitUntilDone wait: Bool, modes array: [String]?) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector, on: thr, with: arg, waitUntilDone: wait, modes: array)
//    }
//
//    @objc open func my_perform(_ aSelector: Selector, on thr: Thread, with arg: Any?, waitUntilDone wait: Bool) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_perform(aSelector, on: thr, with: arg, waitUntilDone: wait)
//    }
//
//    @objc open func my_performSelector(inBackground aSelector: Selector, with arg: Any?) {
//        let selectorDes = String(aSelector.description)
//        checkData(sender: selectorDes)
//        return my_performSelector(inBackground: aSelector, with: arg)
//    }
}
