//
//  String+Encryption.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2021/4/12.
//  Copyright © 2021 zlm. All rights reserved.
//

import Foundation
import CommonCrypto

fileprivate typealias Encryption = String
public extension Encryption {
    var MD5: String {
        let cStrl = cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16);
        CC_MD5(cStrl, CC_LONG(strlen(cStrl!)), buffer);
        var md5String = "";
        for idx in 0...15 {
            let obcStrl = String.init(format: "%02x", buffer[idx]);
            md5String.append(obcStrl);
        }
        free(buffer);
        return md5String;
    }
    var urlEncode: String? {
         var set = CharacterSet.urlQueryAllowed
         set.remove(charactersIn: ":#[]@!$&'()*+,;=")
         return self.addingPercentEncoding(withAllowedCharacters: set)
     }
     
     var urlDecode: String? {
         return self.removingPercentEncoding
     }
}
