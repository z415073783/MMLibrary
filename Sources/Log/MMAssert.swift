//
//  MMAssert.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/8/8.
//

import Foundation
public class MMAssert {
    public class func check(_ condition: Bool, _ closure: @autoclosure () -> String?) {
        #if DEBUG
        assert(condition, closure() ?? "")
        #endif
        if condition == false {
            MMLOG.error(closure())
        }
    }
    public class func fire(_ closure: @autoclosure () -> String?) {
        check(false, closure())
    }
    
}
