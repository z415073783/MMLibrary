//
//  MMLibraryConfig.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/10/19.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
public class MMLibrary {
    static public let shared = MMLibrary()
    public var isDebug = true
    public class func setup() {
        MMSetup.setup()
    }
    
}


