//
//  FileControl.swift
//  writePlist
//
//  Created by zlm on 2018/8/17.
//  Copyright © 2018年 zlm. All rights reserved.
//

import Foundation
public struct ProjectPathModel {
    public var name: String = ""
    public var path: String = ""
    public func fullPath() -> String {
        return path + "/" + name
    }
}

fileprivate typealias Search = MMFileData
extension MMFileData {
    /// 通过根节点查找每个子节点下的指定文件位置
    ///
    /// - Parameters:
    ///   - rootPath: 根目录
    ///   - selectFile: 文件名称
    ///   - isSuffix: 是否是后缀,如果为true,则搜索后缀为selectFile变量的文件
    ///   - onlyOne: 是否查询到第一个就返回
    ///   - 向下递归次数: 99为无限向下递归, 0为不递归
    /// - Returns: <#return value description#>
    public class func searchFilePath(rootPath: String, selectFile: String, isSuffix: Bool = false, onlyOne: Bool = true, recursiveNum: Int = 99, isDirectory: Bool = false) -> [ProjectPathModel] {
        var _rootPath = rootPath
        if _rootPath.count == 0 {
            _rootPath = "./"
        }
        var pathList: [ProjectPathModel] = []
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: _rootPath)
            var subDirList: [String] = []
            for item in list {
                var changeRootPath = _rootPath
                if changeRootPath == "./" {
                    changeRootPath = "."
                }
                if !changeRootPath.hasSuffix("/") {
                    changeRootPath = changeRootPath + "/"
                }
                let newPath = changeRootPath + item
                var isDir: ObjCBool = false
                let isExist = FileManager.default.fileExists(atPath: newPath, isDirectory: &isDir)

                if isDir.boolValue == true && isExist == true {
                    if isDirectory {
                        if item == selectFile || selectFile.count == 0 {
                            //获取到同名文件
                            MMLOG.info("获取到文件路径: \(newPath)")
                            pathList.append(ProjectPathModel(name: item, path: changeRootPath))
                        } else if isSuffix == true {
                            if item.hasSuffix(selectFile) {
                                //找到后缀相同的文件
                                MMLOG.info("获取到后缀相同的文件路径: \(newPath)")
                                pathList.append(ProjectPathModel(name: item, path: changeRootPath))
                            } else {
                                //当前目录是文件夹,则存入文件夹数组,以便进行递归遍历
                                subDirList.append(newPath)
                            }
                        } else {
                            //当前目录是文件夹,则存入文件夹数组,以便进行递归遍历
                            subDirList.append(newPath)
                        }
                    } else {
                        //当前目录是文件夹,则存入文件夹数组,以便进行递归遍历
                        subDirList.append(newPath)
                    }
                
                } else {
                    if item == selectFile || selectFile.count == 0 {
                        //获取到同名文件
                        MMLOG.info("获取到文件路径: \(newPath)")
                        pathList.append(ProjectPathModel(name: item, path: changeRootPath))
                    } else if isSuffix == true {
                        if item.hasSuffix(selectFile) {
                            //找到后缀相同的文件
                            MMLOG.info("获取到后缀相同的文件路径: \(newPath)")
                            pathList.append(ProjectPathModel(name: item, path: changeRootPath))
                        }
                    }
                }
                
                if onlyOne == true, pathList.count == 1 {
                    return pathList
                }
            }

            let newRecursiveNum = recursiveNum >= 99 ? recursiveNum : recursiveNum - 1
            if newRecursiveNum < 0 {
                return pathList
            }
            for subDir in subDirList {
                let subList = searchFilePath(rootPath: subDir, selectFile: selectFile, isSuffix: isSuffix, onlyOne: onlyOne, recursiveNum: newRecursiveNum, isDirectory: isDirectory)
                if subList.count > 0 {
                    pathList += subList
                    if onlyOne == true {
                        return pathList
                    }
                }
            }

        } catch {
            MMLOG.error("传入的根路径不存在: rootPath = \(rootPath)")
        }
        return pathList
    }
    
}