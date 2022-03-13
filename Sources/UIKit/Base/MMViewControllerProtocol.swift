//
//  MMViewControllerProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2022/3/13.
//

import Foundation

public protocol MMViewControllerProtocol {

    var sceneKey: String? { get }
    // 注册
    func register(key: String)
    
    func unregister()
    
}

extension MMViewControllerProtocol where Self: UIViewController {
    
    public var sceneKey: String? {
        get {
            guard let existKey = mm_value(key: "mm_sceneKey") as? String else {
                return nil
            }
            return existKey
        }
        set {
            guard let newKey = newValue as NSString? else {
                assert(false, "转换NSString失败 -> \(newValue ?? "")")
                return
            }
            mm_setValue(key: "mm_sceneKey", value: newKey)
        }
    }
    // 注册
    public func register(key: String) {
        // 指定key进行注册
        sceneKey = key
        guard let existKey = sceneKey else { return }
        MMSceneManager.share.register(key: existKey, vc: self)
    }
    
    public func unregister() {
        guard let existKey = sceneKey else { return }
        MMSceneManager.share.register(key: existKey, vc: nil)
    }
    
}
