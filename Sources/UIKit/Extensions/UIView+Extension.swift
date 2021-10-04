//
//  UIImage+Common.swift
//  MMLibrary
//
//  Created by mac on 2019/5/13.
//  Copyright © 2019 zlm. All rights reserved.
//
#if os(iOS) || os(tvOS)
import UIKit

public extension UIView {
    /**
     *  设置部分圆角(相对布局) 有用到bounds方法, 所以需要在约束设置之后调用
     *
     *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
     *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
     *  @param rect    需要设置的圆角view的rect
     */
    func setRoundCorners(corners: UIRectCorner, radii: CGSize) {
        let rounded = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: radii)
        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.path = rounded.cgPath
        layer.mask = shape
    }
    
    func setRadius(radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) {
        if borderWidth > 0 {
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
        }

        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
//    weak var weakSelf: UIView? {
//        return self
//    }
    /**
     从父类移除
     */
    func removeFromSuperviewMM() {
        removeFromSuperview()
    }

    func removeFromSuperviewAndClearAutoLayoutSettingsMM() {
        removeFromSuperview()
    }


    func converToImage() -> UIImage? {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

//    /// 自定义键盘躲避通知
//    public func addKeyboardNotification() {
//        //add observer
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//    }
//    //关闭键盘躲避通知
//    public func removeKeyboardNotification() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//    }
//    @objc public func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardBound = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else { return }
//        sliderInAction(CGPoint(x: 0, y: -keyboardBound.size.height))
//    }
//    @objc public func keyboardWillHide(notification: NSNotification) {
//        sliderInAction(CGPoint(x: 0, y: 0))
//    }
//    public func keyboardWillChange(notification: NSNotification) {
//
//    }

    /**
     添加点击关闭键盘
     */
    func registerTapEndEditing() {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapEndEditing))
        addGestureRecognizer(gesture)
    }
    @objc func tapEndEditing(_ gesture: UITapGestureRecognizer) {
        endEditing(true)
    }

    /// 判断Point是否在视图内
    ///
    /// - Parameter point: 传入视图上的坐标
    /// - Returns: true or false
    func isInside(point: CGPoint) -> Bool {
        if point.x < 0 || point.y < 0 {
            return false
        }
        if point.x > self.bounds.size.width || point.y > self.bounds.size.height {
            return false
        }
        return true
    }

    /// 添加头像列表
    ///
    /// - Parameters:
    ///   - list: uiimage 列表
    ///   - sizeW: 显示大小
//    func addHeaderListView(list: Array<UIImage>, sizeW: CGFloat) {
//
//        let scale: CGFloat = sizeW / 50
//        var size = 50*scale
//        var pointList: [CGPoint] = []
//
//        switch list.count {
//        case 1:
//            pointList = [CGPoint(x: 25*scale, y: 25*scale)]
//            break
//        case 2:
//            size = 28*scale
//            pointList = [CGPoint(x: 14*scale, y: 14*scale), CGPoint(x: 36*scale, y: 36*scale)]
//            break
//        case 3:
//            size = 22*scale
//            pointList = [CGPoint(x: 25*scale, y: 13*scale), CGPoint(x: 11*scale, y: 37*scale), CGPoint(x: 39*scale, y: 37*scale)]
//            break
//        case 4:
//            size = 22*scale
//            pointList = [CGPoint(x: 11*scale, y: 11*scale), CGPoint(x: 39*scale, y: 11*scale), CGPoint(x: 39*scale, y: 39*scale), CGPoint(x: 11*scale, y: 39*scale)]
//            break
//        case 5:
//            size = 18*scale
//            pointList = [CGPoint(x: 25*scale, y: 9*scale), CGPoint(x: 9*scale, y: 22*scale), CGPoint(x: 41*scale, y: 22*scale), CGPoint(x: 15*scale, y: 41*scale), CGPoint(x: 35*scale, y: 41*scale)]
//            break
//        default:
//
//            break
//        }
//
//        for i in 0..<list.count {
//            let imageView = UIImageView(image: list[i])
//            addSubview(imageView)
//            imageView.snp.makeConstraints({ (make) in
//                make.height.width.equalTo(size)
//                make.center.equalTo(pointList[i])
//            })
//        }
//    }
}
//简单动画
public extension UIView {
    //弹出动画
    func poppingAction() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.duration = mm_kActionDuration
        anim.values = [0, 1.2, 0.9, 1]
        anim.repeatCount = 1
        layer.add(anim, forKey: "transform.scale")
    }
    /**
     淡入
     */
    func fadeInAction(time: TimeInterval = mm_kActionDuration) {
        alpha = 0
        UIView.animate(withDuration: mm_kActionDuration, animations: {[weak self] in
            self?.alpha = 1
        })
    }
    /**
     淡出
     */
    func fadeOutAction(isRemove: Bool = true, time: TimeInterval = mm_kActionDuration,completionBlock:(()->Void)? = nil) -> Void{
        UIView.animate(withDuration: mm_kActionDuration, animations: { [weak self] in
            self?.alpha = 0
            }, completion: { [weak self](final) in
                if isRemove {
                    self?.removeFromSuperviewMM()
                }
                completionBlock?()
        })
    }
    
    /**
     滑入
     
     - parameter position: 目标点
     */
    func sliderInAction(_ position: CGPoint) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.transform = CGAffineTransform(translationX: position.x, y: position.y)
        })
    }

    /**
     滑入
     - parameter position: 目标点
    */
    func sliderInActionWithTime(_ position: CGPoint, time: TimeInterval = mm_kActionDuration) {
        UIView.animate(withDuration: time, animations: { [weak self] in
            self?.transform = CGAffineTransform(translationX: position.x, y: position.y)
        })
    }

    /**
     滑入
     
     - parameter position: 目标点
     */
    func sliderInAction(position: CGPoint, completionBlock:(() -> Void)? = nil) {
        
        UIView.animate(withDuration: mm_kActionDuration, animations: { [weak self] in
            self?.transform = CGAffineTransform(translationX: position.x, y: position.y)
            }, completion: { (_) in
                completionBlock?()
        })
    }
    /**
     滑出
     */
    func sliderOutAction(completionBlock:(() -> Void)? = nil) {
        
        UIView.animate(withDuration: mm_kActionDuration, animations: { [weak self] in
            self?.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                completionBlock?()
        })
    }

}

#endif
