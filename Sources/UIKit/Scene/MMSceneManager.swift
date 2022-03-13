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
        _lock.lock(before: Date(timeIntervalSinceNow: 5))
        if let existVC = vc {
            data[key] = MMWeakObject(value: existVC)
        } else {
            data[key] = nil
        }
        _lock.unlock()
    }
    
    func unregister(key: String) {
        register(key: key, vc: nil)
    }
    
    func value(key: String) -> UIViewController? {
        _lock.lock(before: Date(timeIntervalSinceNow: 5))
        let value = data[key]
        guard let existVC = value?.value else {
            data[key] = nil
            _lock.unlock()
            return nil
        }
        _lock.unlock()
        return existVC
    }
    
}
