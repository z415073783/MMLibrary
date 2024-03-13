//
//  MMView.swift
//  Odin-UC
//
//  Created by zlm on 2016/11/21.
//  Copyright © 2016年 yealing. All rights reserved.
//

import UIKit
//渐变类型
enum BasicViewGradientType {
    case none, line, radius
}
fileprivate var zlm_visualEffectViewKey: UInt8 = 0
open class MMView: UIView {
    // 毛玻璃 参数只在第一次配置中生效
    @discardableResult func zlm_visualEffectView(style: UIBlurEffect.Style) -> UIVisualEffectView {
        return mm_lazyObject(key:&zlm_visualEffectViewKey, Class: UIVisualEffectView.self) {
            let blurEffect = UIBlurEffect(style: style)
            let effectView = UIVisualEffectView(effect: blurEffect)
            self.addSubview(effectView)
            return effectView
        }
    }
    
    private var _gradientType: BasicViewGradientType = .none
    private var _gradientColors: [CGFloat] = []
    private var _gradientfromPoint = CGPoint.zero
    private var _gradienttoPoint = CGPoint.zero
    private var _gradientLocations: [CGFloat] = [0, 1]

//  fromPoint和toPoint范围为 0~1
    public func setLineGradient(beginColor: UIColor, endColor: UIColor,fromPoint: CGPoint, toPoint: CGPoint) {
        guard let beginList = beginColor.cgColor.components, let endList = endColor.cgColor.components else { return }
        _gradientColors = beginList + endList
        _gradientfromPoint = fromPoint
        _gradienttoPoint = toPoint
        _gradientType = .line
    }
    
    public func setGradient(colors: [UIColor], locations: [CGFloat] = [0, 1], fromPoint: CGPoint, toPoint: CGPoint) {
        _gradientColors = []
        colors.forEach { color in
            var colors = color.cgColor.components ?? []
            while colors.count < 4 {
                colors.append(0)
            }
            
            _gradientColors += colors
        }
        _gradientfromPoint = fromPoint
        _gradienttoPoint = toPoint
        _gradientType = .line
        _gradientLocations = locations
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if _gradientType == .line {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = _gradientLocations
            let start = CGPoint(x: _gradientfromPoint.x * rect.size.width, y: _gradientfromPoint.y * rect.size.height)
            let end = CGPoint(x: _gradienttoPoint.x * rect.size.width, y: _gradienttoPoint.y * rect.size.height)
            
            guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: _gradientColors, locations: locations, count: locations.count) else { return }
            context.drawLinearGradient(gradient, start: start, end: end, options: .drawsBeforeStartLocation)
        }
    }
// 传递事件
//    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if openHitTest {
//            var responseView: UIView?
//            self.subviews.forEach { view in
//                if view.frame.contains(point) {
//                    responseView = view
//                    return
//                }
//            }
//            if let _responseView = responseView {
//                return _responseView.hitTest(point, with: event)
//            }
//            return responseView
//        }
//
//        return super.hitTest(point, with: event)
//    }
    /// 是否穿透自己
    public var throughTouch = false
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if throughTouch {
            let hitView = super.hitTest(point, with: event)
            if hitView == self {
                return nil
            }
            return hitView
        }
        return super.hitTest(point, with: event)
    }

    deinit {
        if !Thread.isMainThread {
            MMLOG.error("非主线程deinit UI: \(self)")
        }
        removeTargetMM()
        NotificationCenter.default.removeObserver(self)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        viewDidInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        viewDidInit()
    }
    
    open func viewDidInit() {
        if !Thread.isMainThread {
            MMLOG.error("非主线程初始化UI: \(self)")
        }
    }

    
    
    
    var _tapGesture: UITapGestureRecognizer?
    //添加touch手势
    open func addtargetMM(_ target: AnyObject?, action: Selector) {
        removeTargetMM()
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
        _tapGesture = tapGesture
    }

    open func removeTargetMM() {
        if let tapGesture = _tapGesture {
            removeGestureRecognizer(tapGesture)
            _tapGesture = nil
        }
    }
    
    private var _touchUpInsideCallback:((_ info:MMView?) -> Void)?
    //添加touch手势 block调用
    public func setTouchUpInsideCallBack(block: @escaping (_ view:MMView?) -> Void) {
        _touchUpInsideCallback = block
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpInSide(sender:))))
    }
    @objc private func touchUpInSide(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let _touchUpInsideCallback = _touchUpInsideCallback {
                _touchUpInsideCallback(self)
            }
        }
    }

    private var _MMCallBlock:((_ sender: UIView) -> Void)?
    //添加touch手势
    public func addtarget(block: @escaping (_ sender: UIView) -> Void) {
        _MMCallBlock = block
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for item in touches {
            let point = item.location(in: self)
            if self.isInside(point: point) {
                guard let block = _MMCallBlock else {
                    return
                }
                block(self)
            }
            break
        }
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }

}


