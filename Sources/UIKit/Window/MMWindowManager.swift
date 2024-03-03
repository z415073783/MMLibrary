//
//  MMWindowManager.swift
//  MMBaseFramework
//
//  Created by soft7 on 2018/4/1.
//  Copyright © 2024 zengliangmin. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
protocol MMSceneDelegate {
    var window: UIWindow? { get }
}

public var kAppWindow: UIWindow? {
    if #available(iOS 13.0, *) {
        guard let winScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        if let window = winScene.windows.first {
            return window
        }
    } else {
        MMAssert.fire("没有找到window")
        // Fallback on earlier versions
    }

    return MMWindowManager.shared.initWindow
}

/// 所有应用内部生成的window管理，必须在主线程调用
public class MMWindowManager: NSObject {
    public static let shared = MMWindowManager()
    
    public var initWindow: UIWindow?
    
    var windowHolderArray: [WindowHolder] = []
    
    // 注册app中主动生成的window
    public func registerWindow(_ window: UIWindow) {
        mm_executeOnMainThread {
            for (_, holder) in self.windowHolderArray.enumerated() {
                if holder.window == window {
                    return
                }
            }
            
            let holder = WindowHolder(window)
            self.windowHolderArray.append(holder)
        }
    }
    
    // 反注册app中主动生成的window
    public func unregisterWindow(_ window: UIWindow) {
        mm_executeOnMainThread {
            var hitHolder: WindowHolder?
            for (_, holder) in self.windowHolderArray.enumerated() {
                if holder.window == window {
                    hitHolder = holder
                    break
                }
            }
            
            guard let holder = hitHolder else { return }
            
            if let index = self.windowHolderArray.firstIndex(of: holder) {
                self.windowHolderArray.remove(at: index)
            }
        }
    }
    
    // 获取顶层window(注册过的且显示中的window，与应用默认window中取)
    // 若在非主线程，直接返回应用默认window
    public func topestWindow() -> UIWindow? {
        var returnValue: UIWindow?
        if #available(iOS 13.0, *) {
            guard let winScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return nil
            }
            if let firstWindow = winScene.windows.first {
                returnValue = firstWindow
            }
        }
        if returnValue == nil {
            if let window = UIApplication.shared.delegate?.window {
                returnValue = window
            }
        }
        
        if Thread.isMainThread {
            var userWindow: UIWindow?
            for (_, holder) in windowHolderArray.enumerated() {
                if let window = holder.window, !window.isHidden {
                    
                    if let currentWindow = userWindow,
                        window.windowLevel >= currentWindow.windowLevel {
                        userWindow = window
                    }
                    else {
                        userWindow = window
                    }
                }
            }
            
            if let currentWindow = returnValue {
                if let window = userWindow,
                    window.windowLevel >= currentWindow.windowLevel {
                    returnValue = userWindow
                }
            }
            else {
                returnValue = userWindow
            }
        }
        
        return returnValue
    }
    
    class WindowHolder: NSObject {
        weak var window: UIWindow?

        init(_ window: UIWindow?) {
            super.init()
            self.window = window
        }
    }
}
