//
//  MMColor.swift
//  MMLibrary
//
//  Created by zlm on 2019/9/23.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
public class MMColorManager {
    public static let shared = MMColorManager()
    public var enableDynamic: Bool = false
}

@objc public class MMColor: UIColor {
    //是否允许动态适配颜色
    @objc public convenience init(auto red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0, dynamic: Bool = true) {
        
        if #available(iOS 13.0, *), dynamic, MMColorManager.shared.enableDynamic {
            self.init { (trait) -> UIColor in
//                let alpha = alpha
                var list: [Int] = [red, green, blue]
                
                switch trait.userInterfaceStyle {
                case .light:
                    break
                case .dark:
                    for i in 0 ..< list.count {
                        if list[i] > 200 {
                            list[i] = 255 - list[i]
                        } else if list[i] < 55 {
                            list[i] = ((55 - list[i]) + 200) % 256
                        } else {
                            list[i] = (list[i] + 100) % 256
                        }
                    }
                    
                default:
                    break
                }
                return UIColor(red: CGFloat(list[0]) / 255.0, green: CGFloat(list[1]) / 255.0, blue: CGFloat(list[2]) / 255.0, alpha: alpha)
            }
        } else {
            // Fallback on earlier versions
            self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
        }
    }

    public class func _colorWithHex(hexColor: CLong, alpha: CGFloat, dynamic: Bool = true) -> UIColor {
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))
        let blue = (CGFloat)((hexColor & 0xFF))
        
        return MMColor(auto: Int(red), green: Int(green), blue: Int(blue), alpha: alpha, dynamic: dynamic)
    }

    @objc public class func colorWithHex(hexColor: String, alpha: CGFloat, dynamic: Bool = true) -> UIColor {
        var hex = hexColor
        if hex.hasPrefix("#") {
            hex = hex.filter {$0 != "#"}
        }
        if let hexVal = Int(hex, radix: 16) {
            return MMColor._colorWithHex(hexColor: hexVal, alpha: CGFloat(alpha), dynamic: dynamic)
        }
        else {
            return UIColor.clear
        }
    }

    
    
    
    
}
#endif
