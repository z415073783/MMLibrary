//
//  MMAutoLayout.swift
//  MMUIKit
//
//  Created by 曾亮敏 on 2021/7/29.
//

import Foundation
fileprivate typealias _AutoLayout = UIView
extension _AutoLayout {
    public var mm: MMAutoLayout { return MMAutoLayout(sourceView: self) }
}

public struct MMAutoLayout {
    var sourceView: UIView?
    func operation() -> MMAutoLayoutOperation {
        let operation = MMAutoLayoutOperation()
        operation.sourceView = sourceView
        return operation
    }
    public var left: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.left]
        return operation
    }
    public var top: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.top]
        return operation
    }
    public var right: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.right]
        return operation
    }
    public var bottom: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.bottom]
        return operation
    }
    public var centerX: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.centerX]
        return operation
    }
    public var centerY: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.centerY]
        return operation
    }
    public var center: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.centerX, .centerY]
        return operation
    }
    public var width: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.width]
        return operation
    }
    public var height: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.height]
        return operation
    }
    public var size: MMAutoLayoutOperation {
        let operation = operation()
        operation.positionType = [.width, .height]
        return operation
    }
    
    public func makeAutoLayout(block: (_ maker: MMAutoLayoutMaker) -> Void) {
        let make = MMAutoLayoutMaker()
        make.sourceView = sourceView
        block(make)
        make.install()
    }
    
    func leftTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .left, view: view, positionType: positionType)
    }
    func topTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .top, view: view, positionType: positionType)
    }
    func rightTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .right, view: view, positionType: positionType)
    }
    func bottomTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .bottom, view: view, positionType: positionType)
    }
    func centerXTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .centerX, view: view, positionType: positionType)
    }
    func centerYTo(view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        return positionTo(myPositionType: .centerY, view: view, positionType: positionType)
    }
 
    func positionTo(myPositionType: MMAutoLayoutPositionType, view: UIView, positionType: MMAutoLayoutPositionType) -> CGFloat {
        guard let sourceView = sourceView, let commonSuperView = sourceView.findCommonSuperView(view: view) else {
            assert(false, "没有共同的父视图, 无法计算距离 -> 报这个错的原因是: 对比视图双方至少其中一方最终没有添加到同一个window上(window是所有view的最底层视图)")
            return 0
        }
        let resourceRect = sourceView.coordinate(selectSuperView: commonSuperView)
        let targetRect = view.coordinate(selectSuperView: commonSuperView)

        return sourceView.comparePosition(firstRect: resourceRect, secondRect: targetRect, firstType: myPositionType, secondType: positionType)
    }
    
}




fileprivate typealias _Private = UIView
extension _Private {
    func findCommonSuperView(view: UIView) -> UIView? {
        var targetSuperViewDic: [UIView: Bool] = [:]
        var targetView: UIView? = view
        while let _targetView = targetView {
            targetSuperViewDic[_targetView] = true
            targetView = _targetView.superview
        }
        
        var sourceView: UIView? = self
        while let _sourceView = sourceView {
            if targetSuperViewDic[_sourceView] == true {
                return _sourceView
            }
            sourceView = _sourceView.superview
        }
        return nil
    }
    
    func coordinate(selectSuperView: UIView) -> CGRect {
        var result = CGRect.zero
        if superview == selectSuperView {
            result = frame
        } else {
            result = selectSuperView.convert(frame, from: superview)
        }
        return result
    }
    
    func comparePosition(firstRect: CGRect, secondRect: CGRect, firstType: MMAutoLayoutPositionType, secondType: MMAutoLayoutPositionType) ->CGFloat {
        switch firstType {
        case .left:
            return compareFirstRectLeftPosition(firstRect: firstRect, secondRect: secondRect, secondType: secondType)
        case .top:
            return compareFirstRectTopPosition(firstRect: firstRect, secondRect: secondRect, secondType: secondType)
        case .right:
            return compareFirstRectRightPosition(firstRect: firstRect, secondRect: secondRect, secondType: secondType)
        case .bottom:
            return compareFirstRectBottomPosition(firstRect: firstRect, secondRect: secondRect, secondType: secondType)
        case .centerX, .centerY:
            return compareFirstRectCenterPosition(firstRect: firstRect, secondRect: secondRect, secondType: secondType)
        default:
            break
        }
        return 0
    }
    
    func compareFirstRectLeftPosition(firstRect: CGRect, secondRect: CGRect, secondType: MMAutoLayoutPositionType) -> CGFloat {
        switch secondType {
        case .left:
            return firstRect.minX - secondRect.minX
        case .right:
            return firstRect.minX - secondRect.maxX
        case .centerX:
            return firstRect.minX - secondRect.minX - secondRect.width / 2
        default:
            assert(false, "水平比较, 只能传入left,right,centerX")
            return 0
        }
    }
    func compareFirstRectTopPosition(firstRect: CGRect, secondRect: CGRect, secondType: MMAutoLayoutPositionType) -> CGFloat {
        switch secondType {
        case .top:
            return firstRect.minY - secondRect.minY
        case .bottom:
            return firstRect.minY - secondRect.maxY
        case .centerY:
            return firstRect.minY - secondRect.minY - secondRect.height / 2
        default:
            assert(false, "垂直比较, 只能传入top,bottom,centerY")
        }
    }
    func compareFirstRectRightPosition(firstRect: CGRect, secondRect: CGRect, secondType: MMAutoLayoutPositionType) -> CGFloat {
        switch secondType {
        case .left:
            return firstRect.maxX - secondRect.minX
        case .right:
            return firstRect.maxX - secondRect.maxX
        default:
            assert(false, "水平比较, 只能传入left,right")
            return 0
        }
    }
    func compareFirstRectBottomPosition(firstRect: CGRect, secondRect: CGRect, secondType: MMAutoLayoutPositionType) -> CGFloat {
        switch secondType {
        case .top:
            return firstRect.maxY - secondRect.minY
        case .bottom:
            return firstRect.maxY - secondRect.maxY
        default:
            assert(false, "垂直比较, 只能传入top,bottom")
        }
    }
    func compareFirstRectCenterPosition(firstRect: CGRect, secondRect: CGRect, secondType: MMAutoLayoutPositionType) -> CGFloat {
        switch secondType {
        case .centerX:
            return (firstRect.minX + firstRect.width / 2) - (secondRect.minX + secondRect.width / 2)
        case .centerY:
            return (firstRect.minY + firstRect.height / 2) - (secondRect.minY + secondRect.height / 2)
        case .left:
            return (firstRect.minX + firstRect.width / 2) - secondRect.minX
        case .top:
            return (firstRect.minY + firstRect.height / 2) - secondRect.minY
        case .right:
            return (firstRect.minX + firstRect.width / 2) - (secondRect.minX + secondRect.width)
        case .bottom:
            return (firstRect.minY + firstRect.height / 2) - (secondRect.minY + secondRect.height)
        default:
            assert(false, "比较中心点, 只能传入centerX||centerY||left||top||right||bottom")
            return 0
        }
    }
}
