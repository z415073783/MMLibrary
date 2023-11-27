//
//  MMSetup.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/10/19.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
import UIKit
public class MMSetup {
    static public let shared = MMSetup()
    class func setup() {
      
        UIView.changeMethod()
        
    }

    private var _zipBlock: ((_ fileName: String,_ fileData: Data,_ zipFilePath: URL,_ password: String) -> (Void))?
    public var zipBlock: ((_ fileName: String,_ fileData: Data,_ zipFilePath: URL,_ password: String) -> (Void))? {
        get {
            _zipBlock
        }
        set {
            _zipBlock = newValue
        }
    }
    public func setZip(zipBlock: ((_ fileName: String,_ fileData: Data,_ zipFilePath: URL,_ password: String) -> (Void))?) {
        self.zipBlock = zipBlock
    }
    private var _unZipBlock: ((_ zipUrl: URL,_ destination: URL,_ overwrite: Bool,_ password: String) -> URL?)?
    public var unZipBlock: ((_ zipUrl: URL,_ destination: URL,_ overwrite: Bool,_ password: String) -> URL?)? {
        get {
            return _unZipBlock
        }
        set {
            _unZipBlock = newValue
        }
    }
    public func setUnZip(unZipBlock: ((_ zipUrl: URL,_ destination: URL,_ overwrite: Bool,_ password: String) -> URL?)?) {
        self.unZipBlock = unZipBlock
    }

}
extension UIView {
    /// 配置接口
    class func changeMethod() {
        mm_changeInstanceMethod(className: UIView.self, method1: #selector(addSubview(_:)), method2: #selector(mm_replaceAddSubview(_:)))
    }
    
    // MARK: addSubView之后调用
    @objc func mm_replaceAddSubview(_ view: UIView) {
        mm_replaceAddSubview(view)
        view.mm_addToSuperViewFinish()
    }
    
    // MARK: 默认回调
    @objc open func mm_addToSuperViewFinish() {
    }
    
}

