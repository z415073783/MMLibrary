//
//  MMSqliteProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/4/14.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
/**
 继承MMSqliteProtocol的类要写:
 required init() {
 }
 
 */
public protocol MMSqliteProtocol: MMJSONCodable {
    init()
    //返回需要设置的primaryKey
    static func mm_primaryKey() -> [String]
    //返回需要设置的autoincrement
    static func mm_autoincrement() -> [String]
    //需要忽视的key
    static func mm_ignoreKey() -> [String]
}
//方法默认实现
public extension MMSqliteProtocol {
    static func mm_primaryKey() -> [String] { return [] }
    static func mm_autoincrement() -> [String] { return [] }
    static func mm_ignoreKey() -> [String] { return [] }
}
