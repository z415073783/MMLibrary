//
//  UIView+AutoLayoutExtension.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2024/3/2.
//

import Foundation

// 自适应排列顺序

enum MMAutoArrangeLayoutHandlerArrangeType {
case leftToRight, center, average, rightToLeft
}
fileprivate var autoArrangeLayoutKey: UInt8 = 0

public class MMAutoArrangeLayoutHandler: NSObject {
    
    weak var sourceView: UIView?
    
    public var arrangeList: [UIView] = []
    
    public func updateAverageLayout() {
        guard var containerWidth = sourceView?.bounds.width  else {
            MMAssert.fire("容器层需要bounds有值")
            return
        }
        let subViewCount = Double(arrangeList.count)
        var subViewAllWidth = 0.0
        arrangeList.forEach { subView in
            subViewAllWidth += subView.bounds.width
        }
        if containerWidth < subViewAllWidth {
            MMAssert.fire("容器层宽度不够展示, containerWidth = \(containerWidth), subViewAllWidth = \(subViewAllWidth)")
            return
        }
        
        let spacing = (containerWidth - subViewAllWidth) / (subViewCount + 1)
        
        var lastItem: UIView?
        arrangeList.forEach { itemView in
            itemView.mm.makeAutoLayout { make in
                make.left.equalTo(lastItem?.mm.right ?? sourceView?.mm.left).offset(spacing)
                make.centerY.equalToSuperview()
            }
            lastItem = itemView
        }
    }
    
}

public extension UIView {
    var mm_layoutHandler: MMAutoArrangeLayoutHandler {
        if let handler = objc_getAssociatedObject(self, &autoArrangeLayoutKey) as? MMAutoArrangeLayoutHandler {
            return handler
        }
        let handler = MMAutoArrangeLayoutHandler()
        handler.sourceView = self
        objc_setAssociatedObject(self, &autoArrangeLayoutKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return handler
    }
    
    
    
}
