//
//  MMSqliteProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/4/14.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
public protocol MMSqliteProtocol: MMJSONCodable {
    init()
    //返回需要设置的primaryKey
    static func setPrimaryKey() -> [String]
    //返回需要设置的autoincrement
    static func setAutoincrement() -> [String]
}

