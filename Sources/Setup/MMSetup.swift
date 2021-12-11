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
    class func changeMethod() {
        mm_changeInstanceMethod(className: UIView.self, method1: #selector(addSubview(_:)), method2: #selector(_replaceAddSubview(_:)))
    }
    @objc func _replaceAddSubview(_ view: UIView) {
        _replaceAddSubview(view)
        view.mm_loadView()
    }
    /**
     当添加进父类后回调
     */
    @objc open func mm_loadView() {
    }
}

