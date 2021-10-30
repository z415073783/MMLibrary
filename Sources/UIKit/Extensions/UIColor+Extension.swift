//
//  UIImage+Common.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//
#if os(iOS) || os(tvOS)
import UIKit
public extension UIColor {

    convenience init(MMRed: CGFloat, MMGreen: CGFloat, MMBlue: CGFloat, MMAlpha: CGFloat) {
        self.init(red: MMRed/255.0, green: MMGreen/255.0, blue: MMBlue/255.0, alpha: MMAlpha)
    }
//    16进制的RGBA数组
    convenience init(components: [CGFloat]) {
        self.init(MMRed: components[0], MMGreen: components[1], MMBlue: components[2], MMAlpha: components[3])
    }
    
    class func colorWithHex(hexColor: String, alpha: Float) -> UIColor {
        var hex = hexColor
        if hex.hasPrefix("#") {
            hex = hex.filter {$0 != "#"}
        }
        if let hexVal = Int(hex, radix: 16) {
            return UIColor._colorWithHex(hexColor: hexVal, alpha: CGFloat(alpha))
        }
        else {
            return UIColor.clear
        }
    }

    class func _colorWithHex(hexColor: CLong, alpha: CGFloat) -> UIColor {
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0
        let blue = ((CGFloat)((hexColor & 0xFF))/255.0)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
// 返回16进制的CGFloat类型数组
    func mm_colorRGBAComponents() -> [CGFloat] {
        guard let components = cgColor.components else {
            return []
        }
        func changeInt16(value: CGFloat) -> CGFloat {
            return value * 255
        }
        
        switch cgColor.numberOfComponents {
        case 2:
            let channel = components[0] * 255.0
            return [channel, channel, channel, components[1]]
        case 3:
            return [changeInt16(value: components[0]), changeInt16(value: components[1]), changeInt16(value: components[2]), 1]
        case 4:
            return [changeInt16(value: components[0]), changeInt16(value: components[1]), changeInt16(value: components[2]), components[3]]
        default:
            return []
        }
    }
}
#endif
