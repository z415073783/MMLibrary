//
//  UIViewController+MMLibrary.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/3.
//

import Foundation
import UIKit

public func TopestController(inWindow window: UIWindow? = nil) -> UIViewController? {
    return UIViewController.topestController(inWindow: window)
}

public enum UIViewControllerFindParentControllerOption {
    case first // 找到的第一个
    case last // 找到的最后一个
}

extension UIViewController {
    
    /// 获取当前controller指定class的parentViewController
    ///
    /// - Parameter clazz: 想要获取的parentViewController的class
    /// option: 查找选项
    ///
    /// - Returns: 当前controller指定class的parentViewController
    public func findParentController(forClass clazz: AnyClass,
                              option: UIViewControllerFindParentControllerOption = .first) -> UIViewController? {
        var result: UIViewController? = nil
        
        var currentController = parent
        while let whileController = currentController {
            if whileController.isKind(of: clazz) {
                result = whileController
                
                if option == .first {
                    break
                }
            }
            
            currentController = whileController.parent
        }
        
        return result
    }
    
    
    /// 获取当前App最顶层的controller
    /// 通常为最后被present的controller
    /// 或UITabBarController中显示的controller
    /// 或UINavigationController中显示的controller
    ///
    /// - Returns: 当前App最顶层的controller
    public class func topestController(inWindow window: UIWindow? = nil) -> UIViewController? {
        return topestController(withRootViewController: window?.rootViewController)
    }
    
    private class func topestController(withRootViewController rootViewController: UIViewController? = nil) -> UIViewController? {
        guard let controller = rootViewController ?? MMWindowManager.shared.topestWindow()?.rootViewController else {
            return nil
        }
        
        var findController: UIViewController? = controller
        
        if let presentedViewController = controller.presentedViewController {
            findController = presentedViewController
        }
        else if let tabBarController = controller as? UITabBarController {
            findController = tabBarController.selectedViewController ?? tabBarController.viewControllers?.last
        }
        else if let navigationController = controller as? UINavigationController {
            findController = navigationController.visibleViewController ?? navigationController.viewControllers.last
        }
        else {
            while let vc = findController, vc.isBeingDismissed {
                findController = findController?.presentingViewController
            }
            return findController
        }
        
        if findController == nil {
            return controller
        }
        
        return topestController(withRootViewController: findController)
    }
    
    // 找到上一个vc 包括childVC
    public func mm_lastViewController() -> MMViewController? {
        if let parentController = self.parent as? MMViewController {
            return parentController
        }
        if let navigationVC = self.navigationController {
            var lastVC: MMViewController?
            var isFind: Bool = false
            for item in navigationVC.viewControllers {
                guard let vc = item as? MMViewController else {
                    break
                }
                if vc == self {
                    //找到
                    isFind = true
                    break
                }
                lastVC = vc
            }
            if isFind, let existVC = lastVC {
                return existVC
            }
        }
        // TODO: 查找presentVC
        
        return nil
    }
    
    // 推出当前vc
    public func mm_popViewController(animated: Bool = true) {
        if let nc = self.navigationController, nc.viewControllers.count > 1 {
            nc.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated, completion: {
            })
        }
    }
    
    public func dismissAllVC() {
        var vc = self
        while let existVC = vc.presentingViewController {
            vc = existVC
        }
        vc.dismiss(animated: true) {
            
        }
    }
    
}
