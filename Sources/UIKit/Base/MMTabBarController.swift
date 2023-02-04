//
//  MMTabBarController.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2022/3/13.
//

import UIKit

open class MMTabBarController: UITabBarController, MMViewControllerProtocol {
    
    public convenience init(key: String) {
        self.init()
        register(key: key)
    }
    
    deinit {
        //移出scene
        unregister()
    }
    var _router: MMRouter?
    open var router: MMRouter {
        get {
            if let exist = _router {
                return exist
            }
            if let existVC = self.mm_lastViewController() {
                return existVC.router
            }
            return MMRouterManager.share.router //兜底调用
        }
        set {
            _router = newValue
        }
    }
}
