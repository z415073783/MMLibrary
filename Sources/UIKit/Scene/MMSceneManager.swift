//
//  MMSceneManager.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/4.
//

import Foundation
// VC管理器
public class MMSceneManager {
    static let share = MMSceneManager()
    
    private var _lock: NSLock = NSLock()
    private lazy var data: [String: MMWeakObject<UIViewController>] = {
        var _data: [String: MMWeakObject<UIViewController>] = [:]
        return _data
    }()
    
    func register(key: String, vc: UIViewController?) {
        _lock.lock()
        if let existVC = vc {
            if data[key] != nil {
                _lock.unlock()
                MMAssert.fire("identifier已存在, 请修改")
                return
            }
            data[key] = MMWeakObject(value: existVC)
            MMLOG.info("vc注册成功: key = \(key), vc = \(existVC)")
        } else {
            data[key] = nil
        }
        _lock.unlock()
    }
    
    func unregister(key: String) {
        register(key: key, vc: nil)
    }
    
    func value<T: UIViewController>(key: String, ClassType: T.Type) -> T? {
        _lock.lock()
        let value = data[key]
        guard let existVC = value?.value as? T else {
            data[key] = nil
            _lock.unlock()
            return nil
        }
        _lock.unlock()
        return existVC
    }
    
}
