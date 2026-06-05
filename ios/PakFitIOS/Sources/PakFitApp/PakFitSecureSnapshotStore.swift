import Foundation
import Security

enum PakFitSecureSnapshotStoreError: Error {
    case invalidPayload
    case keychainStatus(OSStatus)
}

final class PakFitSecureSnapshotStore {
    private let service = "com.pakfit.ios.local-snapshot"
    private let account = "pakfit-sensitive-snapshot"

    func save(_ payload: String) throws {
        guard let data = payload.data(using: .utf8) else {
            throw PakFitSecureSnapshotStoreError.invalidPayload
        }

        let query = baseQuery()
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        if updateStatus != errSecItemNotFound {
            throw PakFitSecureSnapshotStoreError.keychainStatus(updateStatus)
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw PakFitSecureSnapshotStoreError.keychainStatus(addStatus)
        }
    }

    func restoreOrNil() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func clear() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PakFitSecureSnapshotStoreError.keychainStatus(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
