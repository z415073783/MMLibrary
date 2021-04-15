# MMLibrary
## 集合了一些常用基础组件, 远比市面上其他相同功能的组件轻便得多, 基本不占用ipa包大小, 适合作为基础框架的一部分.
### 提供以下功能:
#### 1.文件压缩/解压
#### 2.文件读写
#### 3.Sqlite操作及链式接口
#### 4.日志模块 提供日志高效率打印和压缩
#### 5.其他很多小功能


## framework编译方式:
双击运行AutoBuildLibrary执行文件, 在当前目录下会生成Build文件夹
framework生成路径: Build->MMLibrary.framework






# 功能:

## 数据库使用方式
```
sqliteLink = MMSqliteLink(name: "test", isQueue: true) { (isFinish, link) in
    link?.tableName(name: "表名").createTable(bodyClass: TestModel()) { (finish, list) in
        MMLOG.info("finish = \(finish)")
//                link?.update()
        let model = TestModel()
        model.name = "小曾"
        model.num = 1
        model.ago = 18
        model.identify = 1
        link?.insert(bodyClass: model) { (finish) in
            model.ago = 19
            link?.replace(bodyClass: model, block: { (finish) in
                link?.select(bodyClass: TestModel.self, confitions: ["ago": "18"], block: { (finish, list) in
                })
            })
        }
    }
}
```

```
sqliteLink = MMSqliteLink(name: "test", isQueue: true) { (isFinish, link) in
    MMLOG.debug("zlm = 2")
    // 删除表
    link?.tableName(name: "table1").deleteTable.execute(block: { (finish, list) in
        MMLOG.debug("删除表结果: \(finish)")
    })
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
```
