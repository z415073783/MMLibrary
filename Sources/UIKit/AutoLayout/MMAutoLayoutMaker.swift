//
//  MMAutoLayoutMaker.swift
//  MMUIKit
//
//  Created by 曾亮敏 on 2021/7/29.
//

import Foundation
import UIKit
//public extension ConstraintView {
//    public var snpSafe: ConstraintBasicAttributesDSL {
//        if #available(iOS 11.0, *) {
//            return self.safeAreaLayoutGuide.snp
//        } else {
//            return self.snp
//        }
//    }
//}

//extension MMAutoLayoutMaker {
//    //距离顶部(自动适配安全距离) 传入控制器的view
//    public func safeAreaToTop(_ view: UIView,_ offset: Double = 0) {
//        if #available(iOS 11.0, *) {
//            top.equalTo(view.safeAreaLayoutGuide).offset(offset)
//        } else {
//            top.equalTo(view).offset(20 + offset)
//        }
//    }
//    //距离底部(自动适配安全距离) 传入控制器的view
//    public func safeAreaToBottom(_ view: UIView,_ offset: Double = 0) {
//        if #available(iOS 11.0, *) {
//            bottom.equalTo(view.safeAreaLayoutGuide).offset(offset)
//        } else {
//            bottom.equalTo(view).offset(offset)
//        }
//    }
//
//    public func safeAreaLeftMargin(_ view: UIView, _ offset: CGFloat = 0) {
//        if #available(iOS 11.0, *) {
//            left.equalTo(view.safeAreaLayoutGuide).offset(offset)
//        } else {
//            left.equalTo(view).offset(offset)
//        }
//    }
//    public func safeAreaRightMargin(_ view: UIView, _ offset: CGFloat = 0) {
//        if #available(iOS 11.0, *) {
//            right.equalTo(view.safeAreaLayoutGuide).offset(offset)
//        } else {
//            right.equalTo(view).offset(offset)
//        }
//    }
//}

public class MMAutoLayoutMaker {
    let defaultTypeList: [MMAutoLayoutPositionType] = {
        return [.none, .width, .height, .centerX, .centerY, .left, .top, .right, .bottom]
    }()
    var _leftProcessed: Bool = false
    var _topProcessed: Bool = false
    
    
    var sourceView: UIView?
    var data: [MMAutoLayoutOperation] = []
    
    public var left: MMAutoLayoutMaker {
        queryOperation(type: [.left])
        return self
    }
    public var right: MMAutoLayoutMaker {
        queryOperation(type: [.right])
        return self
    }
    public var top: MMAutoLayoutMaker {
        queryOperation(type: [.top])
        return self
    }
    public var bottom: MMAutoLayoutMaker {
        queryOperation(type: [.bottom])
        return self
    }
    public var edges: MMAutoLayoutMaker {
        queryOperation(type: [.left, .top, .right, .bottom])
        return self
    }
    public var width: MMAutoLayoutMaker {
        queryOperation(type: [.width])
        return self
    }
    public var height: MMAutoLayoutMaker {
        queryOperation(type: [.height])
        return self
    }
    public var size: MMAutoLayoutMaker {
        queryOperation(type: [.width, .height])
        return self
    }
    public var centerX: MMAutoLayoutMaker {
        queryOperation(type: [.centerX])
        return self
    }
    public var centerY: MMAutoLayoutMaker {
        queryOperation(type: [.centerY])
        return self
    }
    public var center: MMAutoLayoutMaker {
        queryOperation(type: [.centerX, .centerY])
        return self
    }
    
    @discardableResult public func equalToSuperview() -> MMAutoLayoutMaker {
        return self.equalTo(sourceView?.superview)
    }
    
    @discardableResult public func equalTo(_ refer: AutoLayoutRelatableTarget?) -> MMAutoLayoutMaker {
        if let referOperation = refer as? MMAutoLayoutOperation {
            currentOperation.refer = referOperation.sourceView
            currentOperation.referPositionType = referOperation.positionType
        } else {
            currentOperation.refer = refer
        }
        return self
    }
    @discardableResult public func offset(_ offset: CGFloat) -> MMAutoLayoutMaker {
        currentOperation.offset = offset
        return self
    }
}
fileprivate typealias _Private = MMAutoLayoutMaker
extension _Private {
    func queryOperation(type: [MMAutoLayoutPositionType]) {
        var operation: MMAutoLayoutOperation?
        for i in 0 ..< data.count {
            let item = data[i]
            if item.positionType == type {
                operation = item
                data.remove(at: i)
                break
            }
        }
        if operation == nil {
            operation = MMAutoLayoutOperation()
            operation?.positionType = type
        } else {
            operation?.positionType += type
        }
        if let operation = operation {
            data.append(operation)
        }
    }
    var currentOperation: MMAutoLayoutOperation {
        if self.data.count == 0 {
            _ = edges
        }
        return data.last ?? MMAutoLayoutOperation()
    }
    
    func install() {
        //补全数据
        chainOperationDataCompletion()
        //细分数据
        let resultData = segmentData()
        //最终计算
        calculate(list: resultData)
    }
    
    func calculate(list: [MMAutoLayoutOperation]) {
        list.forEach { obj in
            
            if let _ = obj.refer as? UIView {
                dealReferView(operation: obj)
            } else if let _ = obj.refer as? CGFloat {
                dealReferNumber(operation: obj)
            } else if let objInt = obj.refer as? Int {
                obj.refer = CGFloat(objInt) //转换类型
                dealReferNumber(operation: obj)
            } else if let _ = obj.refer as? CGPoint {
                dealReferValue(operation: obj)
            } else if let _ = obj.refer as? CGSize {
                dealReferValue(operation: obj)
            }

        }
    }
    func dealReferView(operation: MMAutoLayoutOperation) {
        guard let referView = operation.refer as? UIView else {
            return
        }
        let referFrame: CGRect = referView.frame
        guard var frame: CGRect = sourceView?.frame else {
            return
        }
        let offset = singleCalculatePositionType(operation: operation)
        dealSizeReferView(operation: operation, offset: offset, frame: &frame, referFrame: referFrame)
        dealCenterReferView(operation: operation, offset: offset, frame: &frame, referFrame: referFrame)
        dealPositionReferView(operation: operation, offset: offset, frame: &frame, referFrame: referFrame)
        sourceView?.frame = frame
    }
    
    func dealReferNumber(operation: MMAutoLayoutOperation) {
        guard let floatNumber = operation.refer as? CGFloat, let sourceView = sourceView else {
            return
        }
        var frame = sourceView.frame
        switch operation.curPositionType() {
        case .width:
            frame = CGRect(origin: frame.origin, size: CGSize(width: floatNumber, height: frame.height))
        case .height:
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: floatNumber))
        case .centerX, .centerY:
            /// 不用改
            break
        default:
            break
        }
        sourceView.frame = frame
    }
    func dealReferValue(operation: MMAutoLayoutOperation) {
        guard let sourceView = sourceView else {
            return
        }
        var frame = sourceView.frame
        switch operation.curPositionType() {
        case .width:
            guard let size = operation.refer as? CGSize else {
                assert(false, "类型错误, 需要传入CGSize")
                return
            }
            frame = CGRect(origin: frame.origin, size: CGSize(width: size.width, height: frame.height))
        case .height:
            guard let size = operation.refer as? CGSize else {
                assert(false, "类型错误, 需要传入CGSize")
                return
            }
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: size.height))
        case .centerX:
            guard let point = operation.refer as? CGPoint else {
                assert(false, "类型错误, 需要传入CGPoint")
                return
            }
            frame = CGRect(origin: CGPoint(x: point.x, y: frame.minY), size: frame.size)
        case .centerY:
            guard let point = operation.refer as? CGPoint else {
                assert(false, "类型错误, 需要传入CGPoint")
                return
            }
            frame = CGRect(origin: CGPoint(x: frame.minX, y: point.y), size: frame.size)
        default:
            break
        }
        sourceView.frame = frame
    }
    // 处理sizeType  frame为地址
    func dealSizeReferView(operation: MMAutoLayoutOperation, offset: CGFloat, frame: inout CGRect, referFrame: CGRect) {
        
        switch operation.curPositionType() {
        case .width:
            frame = CGRect(origin: frame.origin, size: CGSize(width: referFrame.width + operation.offset, height: frame.height))
        case .height:
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: referFrame.height + operation.offset))
        default:
            break
        }
    }
    func dealCenterReferView(operation: MMAutoLayoutOperation, offset: CGFloat, frame: inout CGRect, referFrame: CGRect) {
        switch operation.curPositionType() {
        case .centerX:
            frame = CGRect(origin: CGPoint(x: frame.minX + offset, y: frame.minY), size: frame.size)
        case .centerY:
            frame = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY + offset), size: frame.size)
        default:
            break
        }
    }
    func dealPositionReferView(operation: MMAutoLayoutOperation, offset: CGFloat, frame: inout CGRect, referFrame: CGRect) {
        let leftProcessed = _leftProcessed
        let topProcessed = _topProcessed
        func rightTypeDeal() {
            if leftProcessed {
                frame = CGRect(origin: frame.origin, size: CGSize(width: offset + frame.width, height: frame.height))
            } else {
                frame = CGRect(origin: CGPoint(x: frame.minX + offset, y: frame.minY), size: frame.size)
            }
        }
        func bottomTypeDeal() {
            if topProcessed {
                frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: offset + frame.height))
            } else {
                frame = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY + offset), size: frame.size)
            }
        }
        switch operation.curPositionType() {
        case .left:
            frame = CGRect(origin: CGPoint(x: frame.minX + offset, y: frame.minY), size: frame.size)
            _leftProcessed = true
        case .right:
            rightTypeDeal()
        case .top:
            frame = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY + offset), size: frame.size)
            _topProcessed = true
        case .bottom:
            bottomTypeDeal()
        default:
            return
        }
    }
    
    func singleCalculatePositionType(operation: MMAutoLayoutOperation) -> CGFloat {
        guard let sourceView = sourceView, let referView = operation.refer as? UIView else {
            return 0
        }
        var preOffset: CGFloat = 0
        switch operation.curPositionType() {
        case .left:
            preOffset = sourceView.mm.leftTo(view: referView, positionType: operation.curReferPositionType())
        case .right:
            preOffset = sourceView.mm.rightTo(view: referView, positionType: operation.curReferPositionType())
        case .top:
            preOffset = sourceView.mm.topTo(view: referView, positionType: operation.curReferPositionType())
        case .bottom:
            preOffset = sourceView.mm.bottomTo(view: referView, positionType: operation.curReferPositionType())
        case .centerX:
            preOffset = sourceView.mm.centerXTo(view: referView, positionType: operation.curReferPositionType())
        case .centerY:
            preOffset = sourceView.mm.centerYTo(view: referView, positionType: operation.curReferPositionType())
        default:
            break
        }
        
        return operation.offset - preOffset
    }
    
}

typealias _Calculate = MMAutoLayoutMaker
extension _Calculate {
    func chainOperationDataCompletion() {
        // 链式操作数据补全
        for i in (0 ..< data.count).reversed() {
            let operation = data[i]
            if operation.refer == nil && i != data.count - 1 {
                let lastIndex = i + 1
                if data.count > lastIndex {
                    let lastOperation = data[lastIndex]
                    operation.refer = lastOperation.refer
                    operation.offset = lastOperation.offset
                    operation.referPositionType = lastOperation.referPositionType
                }
//                data[i] = operation //反向写入
            }
        }
    }
    
    
    func segmentData() -> [MMAutoLayoutOperation] {
        var resultData: [MMAutoLayoutOperation] = []
        for item in defaultTypeList {
            data.forEach { obj in
                if obj.positionType.contains(item) {
                    let referTypes: [MMAutoLayoutPositionType] = obj.referPositionType
                    let operation = setupOperation(sourceView: sourceView, refer: obj.refer, positionType: [item], referPositionType: referTypes, offset: obj.offset)
                    resultData.append(operation)
                }
            }
        }
        return resultData
    }
    
    func setupOperation(sourceView: UIView?, refer: Any?, positionType: [MMAutoLayoutPositionType], referPositionType: [MMAutoLayoutPositionType], offset: CGFloat) -> MMAutoLayoutOperation {
        let operation = MMAutoLayoutOperation()
        operation.sourceView = sourceView
        operation.refer = refer
        operation.positionType = positionType
        operation.referPositionType = referPositionType.count == 0 ? positionType : referPositionType
        operation.offset = offset
        return operation
    }
    
    
    
    
}

