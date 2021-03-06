//
//  MMUIKit.swift
//  MMUIKit
//
//  Created by yealink-dev on 2018/7/6.
//
#if os(iOS) || os(watchOS) || os(tvOS)
import Foundation
import UIKit



/** 屏幕宽度  */
public var mm_kScreenWidth: Float {
    get {
        return Float(UIScreen.main.bounds.size.width)
    }
}

/** 屏幕高度  */
public var mm_kScreenHight: Float {
    get {
        return Float(UIScreen.main.bounds.size.height)
    }
}

public var mm_kRootViewController: UIViewController? {
    if #available(iOS 13.0, *) {
        guard let winScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        for window in winScene.windows {
            if window.isKeyWindow {
                return window.rootViewController
            }
        }

//        if let delegate = winScene.delegate as? SceneDelegate, let window = delegate.window {
//            let vc = window.rootViewController
//            return vc
//        }
        
        return nil
    } else {
        // Fallback on earlier versions
        for window in UIApplication.shared.windows {
            if window.isKeyWindow {
                return window.rootViewController
            }
        }
        
        return nil
    }
}
#endif
