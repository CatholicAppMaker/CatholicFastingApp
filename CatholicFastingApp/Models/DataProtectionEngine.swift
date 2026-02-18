@preconcurrency import Foundation
#if canImport(CryptoKit)
  import CryptoKit
#endif

enum DataProtectionEngine {
  static func encrypt(plaintext: String, passphrase: String) -> String? {
    guard !passphrase.isEmpty else { return nil }
    #if canImport(CryptoKit)
      let key = SymmetricKey(data: SHA256.hash(data: Data(passphrase.utf8)))
      guard
        let sealed = try? AES.GCM.seal(Data(plaintext.utf8), using: key),
        let combined = sealed.combined
      else {
        return nil
      }
      return combined.base64EncodedString()
    #else
      return nil
    #endif
  }

  static func decrypt(base64Ciphertext: String, passphrase: String) -> String? {
    guard !passphrase.isEmpty else { return nil }
    #if canImport(CryptoKit)
      guard
        let data = Data(base64Encoded: base64Ciphertext),
        let box = try? AES.GCM.SealedBox(combined: data)
      else {
        return nil
      }
      let key = SymmetricKey(data: SHA256.hash(data: Data(passphrase.utf8)))
      guard
        let opened = try? AES.GCM.open(box, using: key)
      else {
        return nil
      }
      return String(data: opened, encoding: .utf8)
    #else
      return nil
    #endif
  }
}
