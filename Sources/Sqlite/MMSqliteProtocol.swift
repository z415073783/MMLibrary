//
//  MMSqliteProtocol.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/4/14.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
public protocol MMSqliteProtocol: MMJSONCodable {
    /// 唯一 递增
    var identify: Int? { get set }
}

