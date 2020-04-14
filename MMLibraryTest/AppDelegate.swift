//
//  AppDelegate.swift
//  MMLibraryTest
//
//  Created by zlm on 2019/12/29.
//  Copyright © 2019 zlm. All rights reserved.
//

import UIKit
import MMLibrary
@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {

    class TestObj: NSObject {
        var key: String?
        var value: String?
    }
    var sqliteLink: MMSqliteLink?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MMLOG.debug("启动程序")
        sqliteLink = MMSqliteLink(name: "test") { (isFinish, link) in
            link?.tableName(name: "table1").createTable.property(name: "姓名").primarykey.text.property(name: "年龄").integer.property(name: "身高").text.execute(block: { [weak self](isSuccess, result) in
                MMLOG.debug("创建表结果: \(isSuccess)")
//                self?.sqliteLink?.close()
                
                //查询
//                link?.tableName(name: "table1").select(names: ["姓名"]).whereEqual(key: "", value: <#T##String#>)
                // 插入
                link?.tableName(name: "table1").insert().set(key: "姓名", value: "'李四'").set(key: "年龄", value: "21").set(key: "身高", value: "'178'").execute(block: { (isSuccess, result) in
                    MMLOG.debug("插入数据结果: \(isSuccess)")
                })
                
                
                
                
            })
        }
        
//        let sqlite = MMSqliteLink(name: "aa") { (isOk) in
//        }
//        sqlite.createTable(name: "table1")
        
        return true
        var systemDic: [String: TestObj] = [:]
        let treeDic = MMTree()
        
        treeDic.setNode(key: "a", value: TestObj())
        treeDic.setNode(key: "b", value: TestObj())
        treeDic.setNode(key: "c", value: TestObj())
        treeDic.setNode(key: "d", value: TestObj())
        treeDic.setNode(key: "e", value: TestObj())
        treeDic.setNode(key: "f", value: TestObj())
        treeDic.setNode(key: "g", value: TestObj())
        treeDic.setNode(key: "h", value: TestObj())
        treeDic.setNode(key: "i", value: TestObj())
        treeDic.setNode(key: "j", value: TestObj())
        treeDic.setNode(key: "k", value: TestObj())
        treeDic.setNode(key: "l", value: TestObj())
        treeDic.setNode(key: "m", value: TestObj())
        treeDic.setNode(key: "n", value: TestObj())
        treeDic.setNode(key: "o", value: TestObj())
        treeDic.setNode(key: "p", value: TestObj())
        treeDic.setNode(key: "q", value: TestObj())
        treeDic.setNode(key: "r", value: TestObj())
        
        
        var list: [String] = []
        for _ in 0 ..< 500000 {
            let rand = arc4random()
            list.append("\(rand)")

        }

        
        
        
        MMLOG.debug("二叉树存入")
        for i in 0 ..< list.count {
            let item = list[i]
            if i == list.count - 1 {
                MMLOG.debug("二叉树存入 i = \(i)")
            }
            let obj = TestObj()
            obj.key = item
            obj.value = item
            treeDic.setNode(key: item, value: obj)


        }
        MMLOG.debug("二叉树存入结束")
        MMLOG.debug("字典存入")
        for i in 0 ..< list.count {
            let item = list[i]
            let obj = TestObj()
            obj.key = item
            obj.value = item
            if i == list.count - 1 {
                MMLOG.debug("字典存入 i = \(i)")
            }
            systemDic[item] = obj


        }
        MMLOG.debug("字典存入结束")


        MMLOG.debug("\n\n\n\n\n-------------------------------------------")
        MMLOG.debug("二叉树删除")
        for item in list {
            treeDic.setNode(key: item, value: nil)
//            break
        }
        MMLOG.debug("二叉树删除结束")
        MMLOG.debug("字典删除")
//        var dicSum = ""

        for item in list {
            systemDic[item] = nil
//            break
        }
        MMLOG.debug("字典删除结束")
        
        
        treeDic.removeAll()
        MMLOG.debug("二叉树清空结束")
        systemDic.removeAll()
        MMLOG.debug("字典清空结束")
        //dictionary插入和添加的时间复杂度都是1, 二叉树时间复杂度是logN,但二叉树属于有序容器, 适合应用在有序场景
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

