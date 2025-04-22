//
//  KeychainManager.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import Foundation
import Security

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case notFound
    case unexpectedData
}

class KeychainManager {
    static let shared = KeychainManager()
    private let service = "com.siddharthsehgal.TripCraft"
    
    private init() {}
    
    // For Mistral API
    func saveAPIKey(_ key: String) throws {
        try saveKey(key, for: "HuggingFaceAPIKey")
    }
    
    func getAPIKey() throws -> String {
        try getKey(for: "HuggingFaceAPIKey")
    }
    
    // Generic methods for saving and retrieving keys
    private func saveKey(_ key: String, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try updateKey(key, for: account)
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    private func getKey(for account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.notFound
        }
        
        guard let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        
        return key
    }
    
    private func updateKey(_ key: String, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
}
