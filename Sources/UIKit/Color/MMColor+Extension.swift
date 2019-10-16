//
//  MMColor+Extension.swift
//  MMLibrary
//
//  Created by zlm on 2019/9/23.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
public extension MMColor {
    
//    class var red: MMColor {
//        return MMColor(auto: 1, green: 0, blue: 0)
//    }

    override class var black: UIColor {
        return MMColor(auto: 0, green: 0, blue: 0)
    } // 0.0 white

    override class var darkGray: UIColor {
        return MMColor(auto: Int(0.333 * 255), green: Int(0.333 * 255), blue: Int(0.333 * 255))
    } // 0.333 white

    override class var lightGray: UIColor {
        return MMColor(auto: Int(0.667 * 255), green: Int(0.667 * 255), blue: Int(0.667 * 255))
    } // 0.667 white

    override class var white: UIColor {
        return MMColor(auto: 255, green: 255, blue: 255)
    } // 1.0 white

    override class var gray: UIColor {
        return MMColor(auto: 127, green: 127, blue: 127)
    } // 0.5 white

    override class var red: UIColor {
        return MMColor(auto: 255, green: 0, blue: 0)
    } // 1.0, 0.0, 0.0 RGB

    override class var green: UIColor {
        return MMColor(auto: 0, green: 255, blue: 0)
    } // 0.0, 1.0, 0.0 RGB

    override class var blue: UIColor {
        return MMColor(auto: 0, green: 0, blue: 255)
    } // 0.0, 0.0, 1.0 RGB

    override class var cyan: UIColor {
        return MMColor(auto: 0, green: 255, blue: 255)
    } // 0.0, 1.0, 1.0 RGB

    override class var yellow: UIColor {
        return MMColor(auto: 255, green: 255, blue: 0)
    } // 1.0, 1.0, 0.0 RGB

    override class var magenta: UIColor {
        return MMColor(auto: 255, green: 0, blue: 255)
    } // 1.0, 0.0, 1.0 RGB

    override class var orange: UIColor {
        return MMColor(auto: 255, green: 127, blue: 0)
    } // 1.0, 0.5, 0.0 RGB

    override class var purple: UIColor {
        return MMColor(auto: 127, green: 0, blue: 127)
    } // 0.5, 0.0, 0.5 RGB

    override class var brown: UIColor {
        return MMColor(auto: 153, green: 102, blue: 51)
    } // 0.6, 0.4, 0.2 RGB

    override class var clear: UIColor {
        return MMColor(auto: 0, green: 0, blue: 0, alpha: 0)
    } // 0.0 white, 0.0 alpha

 
}
#endif
