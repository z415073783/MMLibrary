//
//  UIImage+Common.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif
public extension UIImage {
    
    class func mm_imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect.init(x: 0, y: 0, width: 2, height: 2)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let insets: UIEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        return image
    }
    
    func mm_resizeImage(reSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage ?? self
    }
    
    
    //压缩图片
    func mm_compressSize() -> UIImage {
        
        guard let data = self.jpegData(compressionQuality: 1) else { return self }
        let imageLength = data.count
        MMLOG.debug("Image kb = \(imageLength)")
        if imageLength > 600000 {
            let rate = (600000 / (imageLength * 2))
            
            guard let data = self.jpegData(compressionQuality: CGFloat(rate)) else { return self }
            MMLOG.debug("newImage kb = \(data.count)")
            let image = UIImage(data: data) ?? self
            return image
        }
        return self
    }
    //设置图片颜色
//    func MMtintGrayImage() -> UIImage {
//        //        return self.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//        return self.MMimageGrayTranslate()
//        //        return self.addFilter("CIPhotoEffectNoir")
//    }
    
}

