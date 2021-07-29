//
//  MMAutoLayoutOperation.swift
//  MMUIKit
//
//  Created by 曾亮敏 on 2021/7/29.
//

import Foundation
import UIKit
public class MMAutoLayoutOperation {
    weak var sourceView: UIView?
    var positionType: [MMAutoLayoutPositionType] = []
    var refer: Any?
    var referPositionType: [MMAutoLayoutPositionType] = []
    var offset: CGFloat = 0
    
    func curPositionType() -> MMAutoLayoutPositionType {
        return positionType.first ?? .none
    }
    func curReferPositionType() -> MMAutoLayoutPositionType {
        return referPositionType.first ?? .none
    }
    
}
