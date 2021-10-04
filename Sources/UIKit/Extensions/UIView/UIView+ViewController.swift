//
//  UIView+ViewController.swift
//  MMBaseFramework
//
//  Created by soft7 on 2018/5/10.
//
#if os(iOS) || os(tvOS)
import Foundation
import UIKit
extension UIView {
    public func mm_viewController() -> MMViewController? {
        return mm_UIViewController() as? MMViewController
    }
    
    public func mm_UIViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
}
#endif
