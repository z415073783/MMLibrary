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
import CoreGraphics
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
    // 裁剪图片
    func mm_snapshot(rect: CGRect) -> UIImage? {
        let scale = self.scale
        let scaledRect = CGRect(x: rect.origin.x * scale,y: rect.origin.y * scale,width: rect.size.width * scale,height: rect.size.height * scale)
        guard let newCGImage = self.cgImage?.cropping(to: scaledRect) else {
            return nil
        }
        return UIImage(cgImage: newCGImage,scale: scale,orientation: .up)
    }
    
    // 重设尺寸
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
    
    /// 高斯模糊
    /// - Parameters:
    ///   - radius: radius description
    /// - Returns: description
    func mm_createBlurEffect( radius: CGFloat = 8) -> UIImage? {
//        guard let image = image else {
//            return nil
//        }
        let ciImage = CIImage(image: self)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
//        let number = NSNumber(value: radius) //模糊值
        filter?.setValue(radius, forKey: "inputRadius")
        let context = CIContext(options: nil)
        if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage, let cgimage = context.createCGImage(result, from: CGRect(origin: CGPoint.zero, size: self.size))
        {
            let newImage = UIImage(cgImage: cgimage)
            return newImage
        }
        return nil
    }
    
    
    /// 转成灰度图
    /// - Returns: description
    func mm_toGrayscale() -> UIImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
//        var con = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none)
//        UIGraphicsGetCurrentContext()

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue), let cgImage = self.cgImage else {
            return nil
        }
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
        guard let grayImageRef = context.makeImage() else {
            return nil
        }
        let grayImage = UIImage(cgImage: grayImageRef)
        return grayImage
    }
    
    
    /// 添加滤镜
    /// - Parameter name: 滤镜名称
    /// - Returns: description
    func mm_addFilter(name: String) -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        //创建滤镜
        guard let filter = CIFilter(name: name, parameters: [kCIInputImageKey: ciImage]) else {
            return nil
        }
        //已有的值不变, 其他设为默认
        filter.setDefaults()
//        EAGLContext.setCurrent(nil) 弃用
        //获取上下文
        let context = CIContext(options: nil)
        //渲染并输出ciimage
        guard let outputImage = filter.outputImage else {
            return nil
        }
        //创建cgimage句柄
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
    
    
}

#endif

