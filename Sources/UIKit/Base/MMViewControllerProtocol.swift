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
    
    func takeScene<T: UIViewController>(key: String, ClassType: T.Type) -> T?
    
}
fileprivate var MMViewControllerProtocolDefaultSceneKey: UInt8 = 0
public extension MMViewControllerProtocol where Self: UIViewController {
    
    var sceneKey: String? {
        get {
            guard let existKey = mm_value(key: &MMViewControllerProtocolDefaultSceneKey) as? String else {
                return nil
            }
            return existKey
        }
        set {
            guard let newKey = newValue as NSString? else {
                assert(false, "转换NSString失败 -> \(newValue ?? "")")
                return
            }
            mm_setValue(key: &MMViewControllerProtocolDefaultSceneKey, value: newKey)
        }
    }
    // 注册 该框架主要用于push或者pop出的vc管理
    func register(key: String) {
        // 指定key进行注册
        sceneKey = key
        guard let existKey = sceneKey else { return }
        MMSceneManager.share.register(key: existKey, vc: self)
    }
    
    func unregister() {
        guard let existKey = sceneKey else { return }
        MMSceneManager.share.register(key: existKey, vc: nil)
    }
    
    func takeScene<T: UIViewController>(key: String = T.mm_className(), ClassType: T.Type) -> T? {
        return MMSceneManager.share.value(key: key, ClassType: ClassType)
    }
    
}
