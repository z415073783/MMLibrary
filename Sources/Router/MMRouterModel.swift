//
//  MMRouterModel.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//


import Foundation
public class MMRouterModel: NSObject  {
    public var key: String = ""
    public weak var target: NSObject?
    public var handler: ((_ params: Any?, _ finishBlock: ((_ params: Any?) ->Void)?)->Void)?
    public init(target: NSObject? = nil, key: String, handler: ((_ params: Any?, _ finishBlock: ((_ params: Any?) ->Void)?)->Void)?) {
        self.key = key
        self.target = target
        self.handler = handler
    }
}
