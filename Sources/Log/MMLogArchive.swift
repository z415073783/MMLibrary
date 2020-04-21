//
//  MMLogArchive.swift
//  MMLibrary
//
//  Created by zlm on 2020/4/21.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
class MMLogArchive {
    static let shared = MMLogArchive()
    let cacheQueue: MMOperationQueue = MMOperationQueue(maxCount: 1)
    var cacheLogs: [String] = []
    
    
    @discardableResult class func saveLog(log: String) -> Bool {
        shared.cacheQueue.addOperation {
            shared.cacheLogs.append(log)
            
        }
        
        
        return true
    }
    
    
    func writeFile() {
        
    }
    
    
    
    
}
