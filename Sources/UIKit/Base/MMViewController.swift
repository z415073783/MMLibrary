//
//  MMViewController.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/3.
//

import UIKit

@objc public protocol MMViewControllerInterfaceProtocol where Self: NSObject {
    @objc func viewWillTransition(targetVC: MMViewController)
    @objc func viewDidTransition(targetVC: MMViewController)
}

open class MMViewController: UIViewController, MMViewControllerProtocol, MMViewControllerInterfaceProtocol {

    open override func loadView() {
        self.view = mmView
    }
    
    open lazy var mmView: MMView = {
        let view = MMView()
        return view
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let identifier = identifier {
            register(key: identifier)
        }
        self.delegateHandler.addProtocol(target: self)
    }
    /// 唯一标识符 需要在初始化时设置
    open var identifier: String? {
        return nil
    }
//    open var identifier: String?
    
    deinit {
        //移出scene
        unregister()
    }
    
    var _router: MMRouter?
    
    /// 事件转发
    public var router: MMRouter {
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
    
    /// 数据存储&转发
    var _dataSource: MMDataSource?
    public var dataSource: MMDataSource {
        get {
            if let exist = _dataSource {
                return exist
            }
            
            if let existVC = self.mm_lastViewController() {
                return existVC.dataSource
            }
           
            return MMDataSourceManager.share.dataSource //兜底调用
        }
        set {
            _dataSource = newValue
        }
    }
    
    var _uiSystem: ZLMHierarchicalSystem?
    /// 该框架主要 用于childVC管理
    public var uiSystem: ZLMHierarchicalSystem {
        get {
            let system = _uiSystem ?? ZLMHierarchicalSystem(relateVC: self)
            _uiSystem = system
            return system
        }
    }
    
    open override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        _ = initFinish
    }
    lazy var initFinish: Bool = {
        zlm_initFinish()
        return true
    }()
    
    open func zlm_initFinish() {
    }
    /// MMViewControllerProtocol
    public var delegateHandler: MMProtocol = MMProtocol()
    
    @objc public func viewWillTransition(targetVC: MMViewController) {
        
    }
    
    @objc public func viewDidTransition(targetVC: MMViewController) {
        
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        delegateHandler.perform(#selector(viewWillTransition(targetVC:)), object: self)
        DispatchQueue.main.async { [weak self] in
            self?.delegateHandler.perform(#selector(self?.viewDidTransition(targetVC:)), object: self)
        }
    }
    
}
