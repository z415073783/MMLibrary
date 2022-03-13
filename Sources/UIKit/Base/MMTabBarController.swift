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

}
