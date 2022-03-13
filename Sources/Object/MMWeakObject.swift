//
//  MMWeakObject.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2022/3/13.
//

import Foundation

class MMWeakObject<T: NSObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}
