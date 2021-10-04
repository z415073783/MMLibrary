//
//  UINavigationViewController+MMLibrary.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/3.
//

import Foundation
import UIKit

public extension UINavigationController {
    func mm_pushViewController(_ viewController: UIViewController, animated: Bool) {
        //相同Controller不会重复打开
        if type(of: topViewController) != type(of: viewController) {
            viewController.hidesBottomBarWhenPushed = true
            pushViewController(viewController, animated: animated)
        }
    }

    func mm_pushViewControllerFromTop(_ viewController: UIViewController, animated: Bool) {
        if ((topViewController?.mm_className() == viewController.mm_className()) == false) {
            let transition = CATransition.init()
            transition.duration = mm_kNavigationPushActionDuration
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.layer.add(transition, forKey: "")
            viewController.hidesBottomBarWhenPushed = true
            pushViewController(viewController, animated: animated)
        }
    }
    
    @discardableResult
    func mm_popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        return popViewController(animated: animated)
    }
    //推出到起始页
    func mm_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
//
        let list = navigationController?.popToRootViewController(animated: animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
        return list
    }

}
