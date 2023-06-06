////
////  MMRouter+ViewController.swift
////  MMRouter
////
////  Created by zlm on 2020/1/6.
////  Copyright © 2020 zlm. All rights reserved.
////
//
//
//import Foundation
//import UIKit
////import MMBaseFramework
//let kRouterMarkPreNamePush: String = "mm_pushVC"
//let kRouterMarkPreNamePresent: String = "mm_presentVC"
//
//
//
//
//typealias MMPushRouter = MMRouter
//@objc public extension MMPushRouter {
//    func push(name: String, target: UINavigationController, animated: Bool, finishBlock: @escaping () ->Void ) {
//        
//        call(key: kRouterMarkPreNamePush + name, params: [target, animated]) { (_) in
//            finishBlock()
//        }
//    }
//
//    /// 注册push
//    ///
//    /// - Parameters:
//    ///   - target: 调用方对象
//    ///   - name: key值
//    ///   - pushVC: 需要push的ViewController
//    func registerPush(target: NSObject, name: String, pushVC: UIViewController.Type) {
//        let model = MMRouterModel(target: target, key: kRouterMarkPreNamePush + name) { (params, finishBlock) in
//            guard let list = params as? [Any] else { return }
//
//            guard let target = list.first as? UINavigationController, let animated = list.last as? Bool else {
//                return
//            }
//            target.mm_pushViewController(pushVC.init(), animated: animated)
//            if let block = finishBlock {
//                block(nil)
//            }
//        }
//        register(model: model)
//    }
//}
//
//typealias MMPresentRouter = MMRouter
//@objc public extension MMPresentRouter {
//    func present(name: String, target: UIViewController, animated: Bool, finishBlock: @escaping () ->Void ) {
//        call(key: kRouterMarkPreNamePush + name, params: [target, animated]) { (_) in
//            finishBlock()
//        }
//    }
//
//    /// 注册Present
//    ///
//    /// - Parameters:
//    ///   - target: 调用方对象
//    ///   - name: key值
//    ///   - presentVC: 需要Present的ViewController
//    func registerPresent(target: NSObject, name: String, presentVC: UIViewController.Type) {
//        let model = MMRouterModel(target: target, key: kRouterMarkPreNamePush + name) { (params, finishBlock) in
//            guard let list = params as? [Any] else { return }
//            guard let target = list.first as? UIViewController, let animated = list.last as? Bool else {
//                return
//            }
//            target.present(presentVC.init(), animated: animated, completion: {
//                if let block = finishBlock {
//                    block(nil)
//                }
//            })
//        }
//        register(model: model)
//    }
//}
//
//
//
//
//
//
