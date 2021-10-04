//
//  MMDataSource.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/4.
//

import Foundation

public class MMDataSourceManager {
    static let share = MMDataSourceManager()
    var dataSource = MMDataSource()
}

struct MMDataSourceModel {
    var oldValue: Any?
    var newValue: Any?
}

public class MMDataSource {
    private var _data: [String: Any] = [:]
    private var _lock: NSLock = NSLock()
    private var _router: MMRouter = MMRouter()
    
    public func setValue(value: Any, key: String) {
        _lock.lock(before: Date(timeIntervalSinceNow: 5))
        let existValue = _data[key]
        _data[key] = value
        // 通知变更
        let model = MMDataSourceModel(oldValue: existValue, newValue: value)
        _router.call(key: key, params: model)
        _lock.unlock()
    }
    
    public func value(key: String) -> Any? {
        _lock.lock(before: Date(timeIntervalSinceNow: 5))
        let value = _data[key]
        _lock.unlock()
        return value
    }
    
    public func listen(key: String, block:((_ oldValue: Any?, _ value: Any?)->Void)?) {
        _router.register(key: key) { params in
            guard let model = params as? MMDataSourceModel else {
                return
            }
            block?(model.oldValue, model.newValue)
        }
    }
    
    public func removeListen(key: String) {
        _router.unregister(key: key)
    }
}
