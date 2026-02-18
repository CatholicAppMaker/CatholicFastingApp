import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

struct BundleDocument: Codable {
    struct MetadataDocument: Codable {
        let id: String
        let displayName: String
        let version: String
        let effectiveDate: String
        let reviewedDate: String
    }

    struct ChangeDocument: Codable {
        let date: String
        let title: String
        let detail: String
    }

    struct SigningDocument: Codable {
        let keyID: String
        let algorithm: String
        let signature: String

        enum CodingKeys: String, CodingKey {
            case keyID = "key_id"
            case algorithm
            case signature
        }
    }

    let metadata: MetadataDocument
    let changes: [ChangeDocument]
    var signing: SigningDocument?
}

struct CanonicalPayload: Encodable {
    let metadata: BundleDocument.MetadataDocument
    let changes: [BundleDocument.ChangeDocument]
}

enum SignError: Error {
    case usage
    case unsupportedPlatform
    case missingPrivateKey
    case invalidPrivateKey
    case parseFailure
    case encodeFailure
}

func canonicalPayloadData(from document: BundleDocument) throws -> Data {
    let payload = CanonicalPayload(metadata: document.metadata, changes: document.changes)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(payload) else { throw SignError.encodeFailure }
    return data
}

func main() throws {
    guard CommandLine.arguments.count == 3 else { throw SignError.usage }
    #if !canImport(CryptoKit)
    throw SignError.unsupportedPlatform
    #else
    let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
    let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
    let keyID = ProcessInfo.processInfo.environment["RULE_BUNDLE_KEY_ID"] ?? "release-unknown"

    guard
        let privateKeyBase64 = ProcessInfo.processInfo.environment["RULE_BUNDLE_PRIVATE_KEY_B64"],
        let privateKeyData = Data(base64Encoded: privateKeyBase64)
    else {
        throw SignError.missingPrivateKey
    }

    guard
        let rawData = try? Data(contentsOf: inputURL),
        var document = try? JSONDecoder().decode(BundleDocument.self, from: rawData)
    else {
        throw SignError.parseFailure
    }

    guard let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData) else {
        throw SignError.invalidPrivateKey
    }

    let payloadData = try canonicalPayloadData(from: document)
    let signature = try privateKey.signature(for: payloadData)
    document.signing = BundleDocument.SigningDocument(
        keyID: keyID,
        algorithm: "ed25519",
        signature: Data(signature).base64EncodedString()
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let signedData = try? encoder.encode(document) else { throw SignError.encodeFailure }
    try signedData.write(to: outputURL, options: .atomic)

    let publicKey = privateKey.publicKey.rawRepresentation.base64EncodedString()
    print("Signed bundle written to: \(outputURL.path)")
    print("Key ID: \(keyID)")
    print("Public key (base64): \(publicKey)")
    #endif
}

do {
    try main()
} catch SignError.usage {
    fputs("Usage: xcrun swift scripts/sign_rule_bundle.swift <input-json> <output-json>\n", stderr)
    fputs("Environment: RULE_BUNDLE_PRIVATE_KEY_B64, optional RULE_BUNDLE_KEY_ID\n", stderr)
    exit(2)
} catch SignError.unsupportedPlatform {
    fputs("CryptoKit is required on this platform.\n", stderr)
    exit(2)
} catch SignError.missingPrivateKey {
    fputs("Missing RULE_BUNDLE_PRIVATE_KEY_B64 in environment.\n", stderr)
    exit(2)
} catch SignError.invalidPrivateKey {
    fputs("Invalid Ed25519 private key material.\n", stderr)
    exit(2)
} catch {
    fputs("Signing failed: \(error)\n", stderr)
    exit(1)
}
