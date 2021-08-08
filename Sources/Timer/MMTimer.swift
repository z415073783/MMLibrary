//
//  MMTimer.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation

public class MMTimer: NSObject {
    
    public typealias Callbackfunc=(_ timer: MMTimer) -> Void
    
    public var block: Callbackfunc?
    public var timer: Timer?
    
    @objc func timerBlockInvoke(timer: MMTimer) {
        block?(self)
    }
    public func fire() {
        timer?.fire()
    }
    public func invalidate() {
        timer?.invalidate()
        timer = nil
    }
    public var isValid: Bool? {
        return timer?.isValid
    }
    deinit {
        invalidate()
        timer = nil
    }
}
public class MMTimerDefault {
    static let share = MMTimerDefault()
    
    
    
    func start() {
    }
    func end() {
    }
    
    
}


public extension Timer {
    @discardableResult class func mm_scheduledTimer(withTimeInterval: Double, repeats: Bool, block:@escaping ((_ timer: MMTimer)->Void))->MMTimer {
        let target = MMTimer()
        target.block = block
        target.timer = Timer.scheduledTimer(timeInterval: withTimeInterval, target: target, selector: #selector(target.timerBlockInvoke(timer:)), userInfo: nil, repeats: repeats)
        return target
    }
}
