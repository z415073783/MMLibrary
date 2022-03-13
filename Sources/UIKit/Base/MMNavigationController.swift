//
//  MMNavigationController.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2022/3/13.
//

import UIKit

open class MMNavigationController: UINavigationController, MMViewControllerProtocol {
    
    public convenience init(key: String) {
        self.init()
        register(key: key)
    }
    
    public convenience init(rootViewController: UIViewController, key: String) {
        self.init(rootViewController: rootViewController)
        register(key: key)
    }
    
    deinit {
        //移出scene
        unregister()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
