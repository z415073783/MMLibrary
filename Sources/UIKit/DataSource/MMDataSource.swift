//
//  MMDataSource.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/10/4.
//

import Foundation

public class MMDataSourceManager {
    public static let share = MMDataSourceManager()
    public var dataSource = MMDataSource()
}

struct MMDataSourceModel {
    var oldValue: Any?
    var newValue: Any?
}

public class MMDataSource: NSObject {
    
    private var data: [String: MMRouterEventProtocol] = [:]
    lazy var queue: DispatchQueue = {
        let _queue = DispatchQueue(label: self.mm_getAddressIdentifity())
        return _queue
    }()
    private var _router: MMRouter = MMRouter()
    
    public func setValue(_ value: MMRouterEventProtocol) {
        let key = type(of: value).zlm_key
        queue.sync { [weak self] in
            self?.data[key] = value
        }
        _router.push(event: value)
    }
    public func value<T: MMRouterEventProtocol>(_ eventClass: T.Type) -> T? {
        let key = eventClass.zlm_key
        var existValue: MMRouterEventProtocol?
        queue.sync { [weak self] in
            existValue = self?.data[key]
        }
        return existValue as? T
    }
    
    public func listen<T: MMRouterEventProtocol>(_ eventClass: T.Type, fire: Bool = false, block:((_ value: T?)->Void)?) {
        _router.listen(eventClass: eventClass) { params in
            block?(params as? T)
        }
        if fire == true {
            let key = eventClass.zlm_key
            var existValue: MMRouterEventProtocol?
            queue.sync {
                existValue = self.data[key]
            }
            if let value = existValue {
                block?(value as? T)
            }
        }
    }
    
    public func removeListen(key: String) {
        _router.unregister(key: key)
    }
}
