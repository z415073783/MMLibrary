//
//  MMViewController.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/3.
//

import UIKit

open class MMViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var _router: MMRouter?
    open var router: MMRouter {
        get {
            if let exist = _router {
                return exist
            }
            if let parentController = self.parent as? MMViewController {
                return parentController.router
            }
            return MMRouterManager.share.router //兜底调用
        }
        set {
            _router = newValue
        }
    }

    var _dataSource: MMDataSource?
    open var dataSource: MMDataSource {
        get {
            if let exist = _dataSource {
                return exist
            }
            if let parentController = self.parent as? MMViewController {
                return parentController.dataSource
            }
            return MMDataSourceManager.share.dataSource //兜底调用
        }
        set {
            _dataSource = newValue
        }
    }

}
