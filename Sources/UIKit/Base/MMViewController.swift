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
    @objc func zlm_viewWillAppear(targetVC: MMViewController)
    @objc func zlm_viewDidAppear(targetVC: MMViewController)
}

open class MMViewController: UIViewController, MMViewControllerProtocol, MMViewControllerInterfaceProtocol {
    public func zlm_viewDidAppear(targetVC: MMViewController) {
        
    }
    
    public func zlm_viewWillAppear(targetVC: MMViewController) {
        
    }
    
    open override func loadView() {
        self.view = mmView
    }
    
    open lazy var mmView: MMView = {
        let view = MMView()
        view.autoresizesSubviews = true
        return view
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let identifier = identifier {
            register(key: identifier)
        }
        self.delegateHandler.addProtocol(target: self)
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegateHandler.perform(#selector(zlm_viewWillAppear(targetVC:)), object: self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegateHandler.perform(#selector(zlm_viewDidAppear(targetVC:)), object: self)
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
    
    open func didMoveFinish(toParent parent: UIViewController?) {
        
    }
    
    lazy var initFinish: Bool = {
        zlm_initFinish()
        return true
    }()
    
    open func zlm_initFinish() {
    }
    /// MMViewControllerInterfaceProtocol
    public var delegateHandler: MMProtocol = MMProtocol()
    
    @objc open func viewWillTransition(targetVC: MMViewController) {
        
    }
    
    @objc open func viewDidTransition(targetVC: MMViewController) {
        
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        delegateHandler.perform(#selector(viewWillTransition(targetVC:)), object: self)
        DispatchQueue.main.async { [weak self] in
            self?.delegateHandler.perform(#selector(self?.viewDidTransition(targetVC:)), object: self)
        }
    }
    
    open override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return true
        }
        return false
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.presentedViewController != nil {
            return self.presentedViewController?.supportedInterfaceOrientations ?? .all
        }
        return .all
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    // collectionView安全高度
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
}
