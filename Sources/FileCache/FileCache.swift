//
//  FileCache.swift
//  MMLibrary
//
//  Created by zlm on 2021/8/13.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
//class FileCacheItem<T> {
//    var path: String = "" //文件所在路径
//    var item: T? //文件实际数据
//    var id: String = "" //文件所在路径下的唯一标识符
//}
protocol FileCacheItemProtocol {
    init()
}


class FileCache {
    static let share = FileCache()
    
    var rootPath = MMFileData.getDocumentsPath()
    
    func save<T: FileCacheItemProtocol>(class: T, path: String) {
        
        
        
        
        
        
        
        
    }
    
    func select<T: FileCacheItemProtocol>(class: T.Type, id: String, path: String) ->T {
        
        
        
        return T()
    }
    func selectAllItem<T: FileCacheItemProtocol>(class: T.Type, path: String) ->[T] {
        
        
        
        return []
    }
    
    
    
    
    
    
    
    
}

