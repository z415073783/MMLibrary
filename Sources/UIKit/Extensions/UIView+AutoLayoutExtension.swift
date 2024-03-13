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
    
    // MARK: 左/右侧排列 中间只能有一个view
    public enum HandlerDirectionType {
        case left, center, right
    }
    public var directionType: HandlerDirectionType = .left
    public var spaceOffset: CGFloat = 0
    
    public func updateFromDirectionLayout() {
        guard let containerWidth = sourceView?.bounds.width, containerWidth > 0 else {
            MMAssert.fire("容器层需要bounds有值")
            return
        }
        
        var subViewAllWidth = 0.0
        var leftSubViewsWidth = 0.0
        var rightSubViewsWidth = 0.0
        var centerSubViewsWidth = 0.0
        
        arrangeList.forEach { subView in
            subViewAllWidth += subView.bounds.width
            switch subView.zlm_layoutHandler.directionType {
            case .left:
                leftSubViewsWidth += subView.bounds.width
            case .center:
                centerSubViewsWidth += subView.bounds.width
            case .right:
                rightSubViewsWidth += subView.bounds.width
            }
        }
        if containerWidth < subViewAllWidth {
            MMAssert.fire("容器层宽度不够展示, containerWidth = \(containerWidth), subViewAllWidth = \(subViewAllWidth)")
            return
        }
        
        var lastItem: UIView?
        var rightItem: UIView?
        arrangeList.forEach { itemView in
            itemView.mm.makeAutoLayout { make in
                make.centerY.equalToSuperview()
                if itemView.zlm_layoutHandler.directionType == .left {
                    make.left.equalTo(lastItem?.mm.right ?? sourceView?.mm.left).offset(itemView.zlm_layoutHandler.spaceOffset)
                    lastItem = itemView
                } else if itemView.zlm_layoutHandler.directionType == .right {
                    make.right.equalTo(rightItem?.mm.left ?? sourceView?.mm.right).offset(-itemView.zlm_layoutHandler.spaceOffset)
                    rightItem = itemView
                } else if itemView.zlm_layoutHandler.directionType == .center {
                    make.center.equalToSuperview()
                }
            }
        }
    }
    
    // MARK: 平均分配
    public var offsetToBottom: CGFloat = 0
    public func updateAverageLayout() {
        guard let containerWidth = sourceView?.bounds.width  else {
            MMAssert.fire("容器层需要bounds有值")
            return
        }

        var needWidthList: [UIView] = []
        arrangeList.forEach { subView in
            needWidthList.append(subView)
        }
        let itemWidth: CGFloat = (containerWidth) / CGFloat(needWidthList.count != 0 ? needWidthList.count : 1)
        
        var lastItem: UIView?
        arrangeList.forEach { itemView in
            itemView.mm.makeAutoLayout { make in
                make.left.equalTo(lastItem?.mm.right ?? sourceView?.mm.left)
                make.bottom.equalToSuperview().offset(itemView.zlm_layoutHandler.offsetToBottom)
                make.width.equalTo(itemWidth)
            }
            lastItem = itemView
        }
    }
    
}

public extension UIView {
    var zlm_layoutHandler: MMAutoArrangeLayoutHandler {
        if let handler = objc_getAssociatedObject(self, &autoArrangeLayoutKey) as? MMAutoArrangeLayoutHandler {
            return handler
        }
        let handler = MMAutoArrangeLayoutHandler()
        handler.sourceView = self
        objc_setAssociatedObject(self, &autoArrangeLayoutKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return handler
    }

}
