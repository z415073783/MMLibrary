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
        
//        MMZipArchive.createZipPackage(path: <#T##String#>)
        
//        DispatchQueue.global().async {
//            for i in 0 ..< 50000 {
//                MMLOG.debug("日志打印(多线程1): \(i)")
//            }
//        }
//        DispatchQueue.global().async {
//            for i in 0 ..< 50000 {
//                MMLOG.debug("日志打印(多线程2): \(i)")
//            }
//        }
        
//        return true
        let begin = Date().timeIntervalSince1970
        for i in 0 ..< 200000 {
            MMLOG.debug("日志打印: \(i)")
        }
        let end = Date().timeIntervalSince1970
        
        let zbegin = Date().timeIntervalSince1970
//        for i in 0 ..< 200000 {
////            MMLOG.debug("日志打印: \(i)")
//            print("日志打印: \(i)")
//        }
        let zend = Date().timeIntervalSince1970
        MMLOG.debug("耗时 zlm = \(end - begin)")
        MMLOG.debug("耗时 print = \(zend - zbegin)")
        
        
//        let debugTest = ["1", "2"]
//        print("debugTest[2] = \(debugTest[2])")
        
        return true
        
        
        DispatchQueue.global().async {
            MMLOG.debug("DispatchQueue")
        }
        MMLOG.debug("zlm = 1")
        sqliteLink = MMSqliteLink(name: "test", isQueue: true) { (isFinish, link) in
            MMLOG.debug("zlm = 2")
            link?.tableName(name: "table1").createTable.property(name: "uid").primarykey.integer.autoincrement.property(name: "姓名").text.property(name: "年龄").integer.property(name: "身高").text.execute(block: { (isSuccess, result) in
                MMLOG.debug("创建表结果: \(isSuccess)")
                MMLOG.debug("zlm = 3")
                // 插入
                
                link?.tableName(name: "table1").insert(values: ["姓名": "张三", "年龄": 20, "身高": "160cm"]).execute(block: { (isSuccess, result) in
                    MMLOG.debug("zlm = select 1")
                })
                link?.tableName(name: "table1").insert(values: ["姓名": "李四", "年龄": 21, "身高": "161cm"]).execute(block: { (isSuccess, result) in
                    MMLOG.debug("zlm = select 2")
                })
                link?.tableName(name: "table1").insert(values: ["姓名": "王五", "年龄": 22, "身高": "162cm"]).execute(block: { (isSuccess, result) in
                    MMLOG.debug("zlm = select 3")
                })
                MMLOG.debug("zlm = select 4")
                
                link?.tableName(name: "table1").insert().set(key: "姓名", value: "马六").set(key: "年龄", value: 23).set(key: "身高", value: "163cm").execute(block: { (isSuccess, result) in
                    MMLOG.debug("插入数据结果: \(isSuccess)")
                    MMLOG.debug("zlm = 4")
                    //查询
                    link?.tableName(name: "table1").select(names: ["姓名", "年龄"]).whereEqual(key: "身高", value: "160cm").execute(block: { (isSuccess, result) in
                        MMLOG.debug("zlm = 5")
                        MMLOG.debug("查询 isSuccess = \(isSuccess), result = \(result)")
                        
                        //更新
                        link?.tableName(name: "table1").update().set(key: "身高", value: "200cm").whereEqual(key: "身高", value: "163cm").execute(block: { (isSuccess, result) in
                            MMLOG.debug("更新 isSuccess = \(isSuccess), result = \(result)")
                            
                            link?.tableName(name: "table1").select().execute(block: { (isSuccess, result) in
                       
                                MMLOG.debug("查询更新后的数据 isSuccess = \(isSuccess), result = \(result)")
                                
                                //删除
                                link?.tableName(name: "table1").delete().whereLike(key: "身高", value: "160").execute(block: { (isSuccess, result) in
                                    MMLOG.debug("删除身高为160的数据 isSuccess = \(isSuccess)")
                                    link?.tableName(name: "table1").select().execute(block: { (isSuccess, result) in
                                        MMLOG.debug("isSuccess = \(isSuccess), 查询结果 = \(result)")
                                        link?.tableName(name: "table1").delete().execute(block: { (isSuccess, result) in
                                            MMLOG.debug("删除全部数据 isSuccess = \(isSuccess)")
                                            link?.tableName(name: "table1").select().execute(block: { (isSuccess, result) in
                                                MMLOG.debug("isSuccess = \(isSuccess), 查询结果 = \(result)")
                                            })
                                            
                                        })
                                    })
                                })
                            })
                            
                        })
                        
                        
                    })
                })
            })
        }
        
//        let sqlite = MMSqliteLink(name: "aa") { (isOk) in
//        }
//        sqlite.createTable(name: "table1")
        MMLOG.debug("结束")
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

