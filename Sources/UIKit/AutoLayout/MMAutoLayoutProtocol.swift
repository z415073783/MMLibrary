//
//  MMAutoLayoutProtocol.swift
//  MMUIKit
//
//  Created by 曾亮敏 on 2021/7/29.
//

import Foundation
public protocol AutoLayoutRelatableTarget {
}
extension UIView: AutoLayoutRelatableTarget {
}
extension CGSize: AutoLayoutRelatableTarget {
}
extension CGPoint: AutoLayoutRelatableTarget {
}
extension CGFloat: AutoLayoutRelatableTarget {
}
extension Int: AutoLayoutRelatableTarget {
}
extension MMAutoLayoutOperation: AutoLayoutRelatableTarget {
}
