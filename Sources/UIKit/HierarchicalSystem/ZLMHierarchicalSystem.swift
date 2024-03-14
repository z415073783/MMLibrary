//
//  ZLMHierarchicalSystem.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2023/11/27.
//  Copyright © 2023 zengliangmin. All rights reserved.
//

import UIKit
// 用于管理vc上的子vc 这个直接放到vc里面去初始化
open class ZLMHierarchicalSystem: NSObject {
    public weak var relateVC: MMViewController?
    
    public init(relateVC: MMViewController) {
        self.relateVC = relateVC
    }
    
    /// 代表当前vc的视图层级, level越大, 代表层级越高
    open var level: Int = 0
}

public extension ZLMHierarchicalSystem {
    
    /// 上屏
    func addSubScene(_ childController: MMViewController) {
        if Thread.isMainThread == false {
            MMAssert.fire("必须在主线程调用")
            return
        }
        guard let _relateVC = relateVC else {
            MMAssert.fire("未绑定relateVC")
            return
        }
        
        childController.willMove(toParent: _relateVC)
        
        addChildController(childController: childController)

        childController.didMove(toParent: _relateVC)
        
        DispatchQueue.main.async { [weak childController, weak _relateVC] in
            childController?.didMoveFinish(toParent: _relateVC)
        }
    }
    
    /// 下屏
    func removeFromParentScene() {
        relateVC?.willMove(toParent: nil)
        
        relateVC?.view.removeFromSuperview()
        relateVC?.removeFromParent()
        
        relateVC?.didMove(toParent: nil)
    }
}

fileprivate extension ZLMHierarchicalSystem {
    func addChildController(childController: MMViewController) {
        let subViewLevel = childController.uiSystem.level
        for view in relateVC?.view.subviews ?? [] {
            let viewLevel = view.mm_viewController()?.uiSystem.level ?? 0
            if viewLevel > subViewLevel {
                relateVC?.view.insertSubview(childController.view, belowSubview: view)
                relateVC?.addChild(childController)
                return
            }
        }
        relateVC?.view.addSubview(childController.view)
        relateVC?.addChild(childController)
    }
}
