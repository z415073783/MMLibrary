//
//  Data+Encryption.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2024/4/13.
//

import Foundation
import CryptoKit

fileprivate typealias Encryption = Data
extension Encryption {
    // aes加密
    func aesEncryptData(key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(self, using: key)
            return sealedBox.combined
        } catch {
            MMAssert.fire("加密失败 error = \(error)")
            return nil
        }
    }
    // aes解密
    func aesDecryptData(key: SymmetricKey) -> Data? {
        do {
            // 解密数据
            let sealedBox = try AES.GCM.SealedBox(combined: self)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            MMLOG.error("解码成功")
            // 返回解密后的数据
            return decryptedData
        } catch {
            MMLOG.error("解码失败 error = \(error)")
//            MMAssert.fire("解密失败 error = \(error)")
            return self
        }
    }
    
    func aesEncryptData(customKey: String) -> Data? {
        return aesEncryptData(key: createSymmetricKey(customKey: customKey))
    }
    func aesDecryptData(customKey: String) -> Data? {
        return aesDecryptData(key: createSymmetricKey(customKey: customKey))
    }
    
    func createSymmetricKey(customKey: String) -> SymmetricKey {
        
        // 默认自定义密钥数据（32 字节，对应于 256 位密钥）
        let defaultKeyData: [UInt8] = [0x31, 0x39, 0x36, 0x38, 0x31, 0x39, 0x36, 0x39, 0x31, 0x39, 0x38, 0x39, 0x31, 0x39, 0x39, 0x30, 0x7A, 0x65, 0x6E, 0x67, 0x6C, 0x69, 0x61, 0x6E, 0x6D, 0x69, 0x6E, 0x36, 0x36, 0x36, 0x36, 0x36]
        
        var newKey: [UInt8] = defaultKeyData
        if let bytes = customKey.data(using: .utf8) {
            var byteArray = Array(bytes)
            
            while byteArray.count < defaultKeyData.count {
                byteArray.append(defaultKeyData[byteArray.count])
            }
            if byteArray.count > defaultKeyData.count {
                let needList = byteArray.prefix(defaultKeyData.count)
                byteArray = Array(needList)
            }
            newKey = byteArray
        }

        let keyData = Data(newKey)
        return SymmetricKey(data: keyData)
    }
    
}
