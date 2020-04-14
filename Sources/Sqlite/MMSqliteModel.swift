//
//  MMSqliteModel.swift
//  MMLibrary
//
//  Created by zlm on 2020/4/14.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation

struct MMSqliteModel {
    var key: String?
    var value: String?
    //支持三种类型: integer = "INTEGER", text = "TEXT", float = "FLOAT"
    var type: MMSqliteOperationPropertyType = .text
    var primarykey: Bool = false
    var autoincrement: Bool = false
    var unique: Bool = false
}
