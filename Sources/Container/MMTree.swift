//
//  MMTree.swift
//  MMLibrary
//
//  Created by zlm on 2020/3/13.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
enum MMTreeNodeColorType {
    case red, black
}
//节点
class MMNode: NSObject {
    var key: String?
    var value: NSObject?
    var leftSubNode: MMNode?
    var rightSubNode: MMNode?
    weak var superNode: MMNode?
    var color: MMTreeNodeColorType = .red
}
//容器
public class MMTree: NSObject {
    var rootNode: MMNode?
    public func setNode(key: String, value: NSObject?) {
        if let _value = value {
//            添加
            insertNode(key: key, value: _value)
        } else {
//            删除
            removeNode(key: key)
        }
    }
    
    public func getNode(key: String) -> Any? {
        let result = selectNode(key: key, isInsert: false)
        return result.node.value
    }
    public func removeAll() {
        rootNode = nil
    }
    
 
}
fileprivate typealias __TreeControl = MMTree
extension __TreeControl {
    func insertNode(key: String, value: NSObject) {
        
        let result = selectNode(key: key)
        if result.node.value != nil {
//            MMLOG.debug("key(\(key))已存在, 原有value = \(result.node.value ?? "nil"), 新value = \(value)")
        }
        result.node.key = key
        result.node.value = value
        
    }
    
    func removeNode(key: String) {
        //删除
        let result = selectNode(key: key, isInsert: false)
        
        if result.isExist == false {
            if result.node.superNode?.leftSubNode == result.node {
                result.node.superNode?.leftSubNode = nil
            } else {
                result.node.superNode?.rightSubNode = nil
            }
            result.node.superNode = nil
            return
        }
        //找到最接近节点, 替换删除节点
        let needDeleteNode = result.node
        var nearestNode: MMNode?
        if var nearNode = needDeleteNode.leftSubNode {
            
            while let subNode = nearNode.rightSubNode {
                nearestNode = subNode
                nearNode = subNode
            }
            if nearestNode == nil {
                nearestNode = nearNode
            }
            if let leftNearestSubNode = nearestNode?.leftSubNode {
                //右旋
                rightTranslate(translateNode: leftNearestSubNode)
            }
            
        } else if var nearNode = needDeleteNode.rightSubNode {
            while let subNode = nearNode.leftSubNode {
                nearestNode = subNode
                nearNode = subNode
            }
            if nearestNode == nil {
                nearestNode = nearNode
            }
            if let rightNearestSubNode = nearestNode?.rightSubNode {
                //左旋
                leftTranslate(translateNode: rightNearestSubNode)
            }
        } else {
            //未找到替换节点,直接删除
            nearestNode = needDeleteNode
        }
        guard let _nearestNode = nearestNode else {
            MMLOG.error("删除错误")
            return
        }
        
        
//        无兄弟节点则向上查找, 如果找到兄弟节点,则左旋/右旋
        //找兄弟节点, 如果有兄弟节点, 就以父节点为删除节点继续向上查找, 如果
        //            删除
        func deleteAutoBalanceTree(deleteNode: MMNode) {
            guard let fatherNode = deleteNode.superNode else {
                return
            }
            let brotherNode: MMNode?
            if fatherNode.leftSubNode == deleteNode {
                brotherNode = fatherNode.rightSubNode
                //左旋
                if let _brotherNode = brotherNode {
                //变红做左旋
                    fatherNode.color = .black
                    _brotherNode.color = .red
                    leftTranslate(translateNode: _brotherNode)
                    
                } else {
                //            不存在, 把父节点作为删除节点重新循环
                    deleteAutoBalanceTree(deleteNode: fatherNode)
                }
            } else if fatherNode.rightSubNode == deleteNode {
                brotherNode = fatherNode.leftSubNode
                //右旋
                if let _brotherNode = brotherNode {
                                       //变红做
                    fatherNode.color = .black
                    _brotherNode.color = .red
                    rightTranslate(translateNode: _brotherNode)
                } else {
                //            不存在, 把父节点作为删除节点重新循环
                    deleteAutoBalanceTree(deleteNode: fatherNode)
                }
            }
        }
        
        //将最近的node数据赋值给needDeleteNode
        needDeleteNode.key = _nearestNode.key
        needDeleteNode.value = _nearestNode.value
        _nearestNode.key = nil
//        _nearestNode.value = nil
        if _nearestNode.color == .black {
                   //需要自平衡
            
            deleteAutoBalanceTree(deleteNode: _nearestNode)
        }
        
        //删除
        if _nearestNode.superNode?.leftSubNode == _nearestNode {
            _nearestNode.superNode?.leftSubNode = nil
        } else {
            _nearestNode.superNode?.rightSubNode = nil
        }
        _nearestNode.superNode = nil
    }
//    查找指定key节点, 如果节点存在,则返回节点, 如果不存在,则新生成节点并返回
    func selectNode(key: String, isInsert: Bool = true) -> (isExist: Bool, node: MMNode) {
        guard let _rootNode = rootNode, _rootNode.value != nil, _rootNode.key != nil else {
            //创建根节点
            let newNode = MMNode()
            rootNode = newNode
            newNode.key = key
            newNode.color = .black
//            MMLOG.debug("创建根节点 key = \(key)")
            return (false, newNode)
        }
        
        let lastNode = selectLastNode(node: _rootNode, key: key, isInsert: isInsert)
        return ((lastNode.value != nil) ? true : false, lastNode)
    }
    
    /// 右旋
    func rightTranslate(translateNode: MMNode) {
        let fatherNode = translateNode.superNode
        let grandfatherNode = fatherNode?.superNode
        let rightNode = translateNode.rightSubNode

        if grandfatherNode?.rightSubNode == fatherNode {
            grandfatherNode?.rightSubNode = translateNode
        } else {
            grandfatherNode?.leftSubNode = translateNode
        }
        fatherNode?.superNode = translateNode

        translateNode.superNode = grandfatherNode
        translateNode.rightSubNode = fatherNode

        fatherNode?.leftSubNode = rightNode
        rightNode?.superNode = fatherNode
//        MMLOG.debug("右旋结束")
    }
    /// 左旋
    func leftTranslate(translateNode: MMNode) {
        let fatherNode = translateNode.superNode
        let grandfatherNode = fatherNode?.superNode
        let leftNode = translateNode.leftSubNode
        
        if grandfatherNode?.leftSubNode == fatherNode {
            grandfatherNode?.leftSubNode = translateNode
        } else {
            grandfatherNode?.rightSubNode = translateNode
        }
        fatherNode?.superNode = translateNode
        
        translateNode.superNode = grandfatherNode
        translateNode.leftSubNode = fatherNode
        
        fatherNode?.rightSubNode = leftNode
        leftNode?.superNode = fatherNode
//        MMLOG.debug("左旋结束")
    }
    
    
    func autoBalanceTree(insertNode: MMNode) {
        guard let fatherNode = insertNode.superNode else {
            return
        }
        
        if fatherNode.superNode == nil {
            return
        }
        if fatherNode.color == .black {
            insertNode.color = .red
            return
        }
        
        let grandfatherNode = fatherNode.superNode
        let uncleNode: MMNode?
        if grandfatherNode?.leftSubNode == fatherNode {
            uncleNode = grandfatherNode?.rightSubNode
        } else {
            uncleNode = grandfatherNode?.leftSubNode
        }

        //叔叔节点存在并且为红色, 说明需要以祖父节点作为插入节点做自平衡
        if let _uncleNode = uncleNode, _uncleNode.color == .red, grandfatherNode?.superNode != nil {
            
            fatherNode.color = .black
            _uncleNode.color = .black
         
            grandfatherNode?.color = .red
            guard let grandfatherNode = grandfatherNode else {
                MMLOG.error("获取grandfatherNode失败")
                return
            }
            autoBalanceTree(insertNode: grandfatherNode)

            return
        }

        
        if fatherNode == grandfatherNode?.leftSubNode {
            fatherNode.color = .black
            grandfatherNode?.color = .red
            uncleNode?.color = .black
//            if insertNode == fatherNode.leftSubNode {
                
                guard let grandfatherNode = grandfatherNode else {
                    MMLOG.error("获取grandfatherNode失败")
                    return
                }
//                rightTranslate(translateNode: fatherNode)
//            } else {
                rightTranslate(translateNode: fatherNode)
                autoBalanceTree(insertNode: fatherNode)
//            }
        } else {
            fatherNode.color = .black
            grandfatherNode?.color = .red
            uncleNode?.color = .black
//            if insertNode == fatherNode.leftSubNode {
                
                guard let grandfatherNode = grandfatherNode else {
                    MMLOG.error("获取grandfatherNode失败")
                    return
                }
//                rightTranslate(translateNode: grandfatherNode)
//            } else {
                leftTranslate(translateNode: fatherNode)
//                rightTranslate(translateNode: fatherNode)
                autoBalanceTree(insertNode: fatherNode)
//            }
        }
        
        if rootNode == grandfatherNode {
            rootNode = fatherNode
//            if fatherNode.color == .red {
//                fatherNode.color = .black
//            }
        }
        
        
    }
    
    func selectLastNode(node: MMNode, key: String, isInsert: Bool) -> MMNode {
        //比较大小
        let compareResult = node.key?.compare(key)
        switch compareResult {
        case .orderedSame:
//            MMLOG.debug("key(\(key)) == 节点\(node.value ?? "nil")")
//            相等
            return node
        case .orderedAscending:
            if let rightNode = node.rightSubNode {
//                MMLOG.debug("key(\(key)) > 节点\(node.key ?? "nil")")
                return selectLastNode(node: rightNode, key: key, isInsert: isInsert)
            } else {
                let newNode = MMNode()
                node.rightSubNode = newNode
                newNode.superNode = node
//                MMLOG.debug("key(\(key)) > 节点\(node.key ?? "nil"), 且为叶子节点")
                isInsert ? autoBalanceTree(insertNode: newNode) : nil
                return newNode
            }
        case .orderedDescending:
            if let leftNode = node.leftSubNode {
//                MMLOG.debug("key(\(key)) < 节点\(node.key ?? "nil")")
                return selectLastNode(node: leftNode, key: key, isInsert: isInsert)
            } else {
                let newNode = MMNode()
                node.leftSubNode = newNode
                newNode.superNode = node
//                MMLOG.debug("key(\(key)) < 节点\(node.key ?? "nil"), 且为叶子节点")
                isInsert ? autoBalanceTree(insertNode: newNode) : nil
                return newNode
            }
        case .none:
//            比较数据不存在
            MMLOG.emerg("数据比较错误node.key = \(node.key ?? "nil"), key = \(key)")
            return node
        }
    }
    
    
    
    
}


