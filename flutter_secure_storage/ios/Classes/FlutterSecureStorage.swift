//
//  FlutterSecureStorageManager.swift
//  flutter_secure_storage
//
//  Created by Julian Steenbakker on 22/08/2022.
//

import Foundation
import LocalAuthentication

struct FlutterSecureStorageRequest: Decodable {
    
    var key: String?
    var value: String?
    
    var groupId: String?
    var accountName: String?
    
    var accessibility: String?
    var localizedReason: String?
    
    var synchronizable: Bool?
    var useAccessControl: Bool
    var skipAuthenticationItem: Bool
    
    enum CodingKeys: CodingKey {
        case key, value, options
    }
    
    enum OptionsCodingKeys: CodingKey {
        case accountName, groupId
        case accessibility, localizedReason
        case synchronizable, useAccessControl, skipAuthenticationItem
    }
    
    init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        
        key = try vals.decodeIfPresent(String.self, forKey: .key)
        value = try vals.decodeIfPresent(String.self, forKey: .value)
        
        let options = try vals.nestedContainer(keyedBy: OptionsCodingKeys.self, forKey: .options)
        
        groupId = try options.decodeIfPresent(String.self, forKey: .groupId)
        accountName = try options.decodeIfPresent(String.self, forKey: .accountName)
        accessibility = try options.decodeIfPresent(String.self, forKey: .accessibility)
        localizedReason = try options.decodeIfPresent(String.self, forKey: .localizedReason)
        
        synchronizable = try options.decodeBoolIfPresent(forKey: .synchronizable)
        useAccessControl = try options.decodeBoolIfPresent(forKey: .useAccessControl) ?? false
        skipAuthenticationItem = try options.decodeBoolIfPresent(forKey: .skipAuthenticationItem) ?? false
    }
}

struct FlutterSecureStorageResponse {
    var status: OSStatus?
    var value: Any?
}

class FlutterSecureStorage {
    
    private func baseQuery(_ query: FlutterSecureStorageRequest, returnData: Bool? = nil) -> Dictionary<CFString, Any> {
        var keychainQuery: [CFString: Any] = [kSecClass : kSecClassGenericPassword]
        if let key = query.key {
            keychainQuery[kSecAttrAccount] = key
        }
        if let groupId = query.groupId {
            keychainQuery[kSecAttrAccessGroup] = groupId
        }
        
        if let accountName = query.accountName {
            keychainQuery[kSecAttrService] = accountName
        }
        
        if let synchronizable = query.synchronizable {
            keychainQuery[kSecAttrSynchronizable] = synchronizable
        }
        
        if let returnData {
            keychainQuery[kSecReturnData] = returnData
        }
        
        if let localizedReason = query.localizedReason {
            keychainQuery[kSecUseAuthenticationContext] = localizedReason
        }
        
        if (query.skipAuthenticationItem) {
            keychainQuery[kSecUseAuthenticationUI] = kSecUseAuthenticationUISkip
        }
        return keychainQuery
    }
    
    internal func containsKey(_ query: FlutterSecureStorageRequest) -> Bool {
        if read(query).value != nil {
            return true
        } else {
            return false
        }
    }
    
    internal func readAll(_ query: FlutterSecureStorageRequest) -> FlutterSecureStorageResponse {
        var keychainQuery = baseQuery(query, returnData: true)
        
        keychainQuery[kSecMatchLimit] = kSecMatchLimitAll
        keychainQuery[kSecReturnAttributes] = true
        
        var ref: AnyObject?
        let status = SecItemCopyMatching(
            keychainQuery as CFDictionary,
            &ref
        )
        
        var results: [String: String] = [:]
        
        if (status == errSecSuccess) {
            (ref as! NSArray).forEach { item in
                let dic = item as! NSDictionary
                let key: String = dic[kSecAttrAccount] as! String
                let value: String = String(data: dic[kSecValueData] as! Data, encoding: .utf8) ?? ""
                results[key] = value
            }
        }
        
        return FlutterSecureStorageResponse(status: status, value: results)
    }
    
    internal func read(_ query: FlutterSecureStorageRequest) -> FlutterSecureStorageResponse {
        let keychainQuery = baseQuery(query, returnData: true)
        
        var ref: AnyObject?
        let status = SecItemCopyMatching(
            keychainQuery as CFDictionary,
            &ref
        )
        
        var value: String? = nil
        
        if (status == errSecSuccess) {
            value = String(data: ref as! Data, encoding: .utf8)
        }
        return FlutterSecureStorageResponse(status: status, value: value)
    }
    
    internal func deleteAll(groupId: String?, accountName: String?, synchronizable: Bool?) -> OSStatus {
        var keychainQuery: [CFString: Any] = [:];
        if let groupId {
            keychainQuery[kSecAttrAccessGroup] = groupId
        }
        if let accountName {
            keychainQuery[kSecAttrAccount] = accountName
        }
        if let synchronizable {
            keychainQuery[kSecAttrSynchronizable] = synchronizable
        }
        return SecItemDelete(keychainQuery as CFDictionary)
    }
    
    internal func delete(_ query: FlutterSecureStorageRequest) -> OSStatus {
        let keychainQuery = baseQuery(query, returnData: true)
        
        return SecItemDelete(keychainQuery as CFDictionary)
    }
    
    internal func write(_ query: FlutterSecureStorageRequest) -> OSStatus {
        guard
            let _ = query.key,
            let value = query.value
        else {
            return errSecParam
        }
        var attrAccessible: CFString = kSecAttrAccessibleWhenUnlocked
        if let accessibility = query.accessibility {
            switch accessibility {
            case "passcode":
                attrAccessible = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
                break;
            case "unlocked":
                attrAccessible = kSecAttrAccessibleWhenUnlocked
                break
            case "unlocked_this_device":
                attrAccessible = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                break
            case "first_unlock":
                attrAccessible = kSecAttrAccessibleAfterFirstUnlock
                break
            case "first_unlock_this_device":
                attrAccessible = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                break
            default:
                attrAccessible = kSecAttrAccessibleWhenUnlocked
            }
        }
        
        var attrAccessControl: SecAccessControl?
        if query.useAccessControl {
            var error: Unmanaged<CFError>?
            attrAccessControl = SecAccessControlCreateWithFlags(
                nil, attrAccessible, .userPresence, &error)
        }
        
        let keyExists = containsKey(query)
        var keychainQuery = baseQuery(query)
        if (keyExists) {
            var update: [CFString: Any?] = [
                kSecValueData: value.data(using: String.Encoding.utf8),
                kSecAttrSynchronizable: query.synchronizable ?? false
            ]
            if let attrAccessControl {
                update[kSecAttrAccessControl] = attrAccessControl
            }
            else {
                update[kSecAttrAccessible] = attrAccessible
            }
            
            return SecItemUpdate(keychainQuery as CFDictionary, update as CFDictionary)
        } else {
            keychainQuery[kSecValueData] = value.data(using: String.Encoding.utf8)
            if let attrAccessControl {
                keychainQuery[kSecAttrAccessControl] = attrAccessControl
            }
            else {
                keychainQuery[kSecAttrAccessible] = attrAccessible
            }
            return SecItemAdd(keychainQuery as CFDictionary, nil)
        }
    }
}


extension KeyedDecodingContainerProtocol {
    public func decodeBoolIfPresent(forKey key: Self.Key) throws -> Bool? {
        if let str = try? decodeIfPresent(String.self, forKey: key) {
            return Bool(str)
        }
        return try decodeIfPresent(Bool.self, forKey: key)
    }
}
