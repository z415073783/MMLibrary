//
//  UIColor+MMColor.swift
//  UME
//
//  Created by zlm on 16/7/18.
//
#if os(iOS) || os(tvOS)
import UIKit
public extension UIColor {

    convenience init(MMRed: CGFloat, MMGreen: CGFloat, MMBlue: CGFloat, MMAlpha: CGFloat) {
        self.init(red: MMRed/255.0, green: MMGreen/255.0, blue: MMBlue/255.0, alpha: MMAlpha)
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

}
#endif
