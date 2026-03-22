@preconcurrency import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

enum RuleBundleRepository {
    struct BundleSnapshot {
        let metadata: RuleBundleMetadata
        let changes: [RuleBundleChange]
        let audit: RuleBundleAudit
    }

    private struct BundleDocument: Codable {
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
        let signing: SigningDocument?
    }

    static func snapshot() -> BundleSnapshot {
        loadSnapshot()
    }

    private static func loadSnapshot() -> BundleSnapshot {
        var warningsFromLocal: [String] = []
        if let local = loadLocalBundle() {
            let evaluation = decodeBundleDocument(data: local.data)
            if let document = evaluation.document {
                let verification = verify(document: document, explicitSignature: local.signature)
                if verification.isVerified {
                    return makeSnapshot(
                        from: document,
                        source: "local override",
                        verified: true,
                        warnings: verification.warnings)
                }
                warningsFromLocal = verification.warnings + ["Local rule bundle signature check failed. Using bundled rules."]
            } else {
                warningsFromLocal = evaluation.warnings + ["Unable to decode local rule bundle. Using bundled rules."]
            }
        }

        let bundledEvaluation = decodeBundleDocument(data: Data(bundledJSON.utf8))
        guard let bundledDocument = bundledEvaluation.document else {
            return fallbackSnapshot(
                source: "bundled",
                verified: false,
                warnings: warningsFromLocal + bundledEvaluation.warnings + ["Failed to decode bundled rule bundle document."])
        }
        let bundledVerification = verify(document: bundledDocument, explicitSignature: nil)
        return makeSnapshot(
            from: bundledDocument,
            source: "bundled",
            verified: bundledVerification.isVerified,
            warnings: warningsFromLocal + bundledEvaluation.warnings + bundledVerification.warnings)
    }

    private static func decodeBundleDocument(data: Data) -> (document: BundleDocument?, warnings: [String]) {
        guard let document = try? JSONDecoder().decode(BundleDocument.self, from: data) else {
            return (nil, ["Rule bundle decode failed."])
        }
        return (document, [])
    }

    private static func makeSnapshot(
        from document: BundleDocument,
        source: String,
        verified: Bool,
        warnings: [String]) -> BundleSnapshot
    {
        guard
            let effective = DateFormatter.dayKeyParser.date(from: document.metadata.effectiveDate),
            let reviewed = DateFormatter.dayKeyParser.date(from: document.metadata.reviewedDate)
        else {
            return fallbackSnapshot(
                source: source,
                verified: false,
                warnings: warnings + ["Failed to decode rule bundle document."])
        }

        let metadata = RuleBundleMetadata(
            id: document.metadata.id,
            displayName: document.metadata.displayName,
            version: document.metadata.version,
            effectiveDate: effective,
            reviewedDate: reviewed)

        let changes: [RuleBundleChange] = document.changes.compactMap { change -> RuleBundleChange? in
            guard let date = DateFormatter.dayKeyParser.date(from: change.date) else { return nil }
            return RuleBundleChange(
                id: "\(change.date)|\(change.title)",
                date: date,
                title: change.title,
                detail: change.detail)
        }
        .sorted { (lhs: RuleBundleChange, rhs: RuleBundleChange) in lhs.date > rhs.date }

        var allWarnings = warnings
        if reviewed < Calendar.gregorian.date(byAdding: .day, value: -365, to: Date()) ?? reviewed {
            allWarnings.append("Rule bundle appears stale (reviewed over 1 year ago).")
        }

        return BundleSnapshot(
            metadata: metadata,
            changes: changes,
            audit: RuleBundleAudit(source: source, isVerified: verified, warnings: allWarnings))
    }

    private static func fallbackSnapshot(source: String, verified: Bool, warnings: [String]) -> BundleSnapshot {
        let metadata = RuleBundleMetadata(
            id: "fallback-us-rules",
            displayName: "Fallback U.S. Rules",
            version: "fallback-1",
            effectiveDate: Calendar.gregorian.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(),
            reviewedDate: Date())
        return BundleSnapshot(
            metadata: metadata,
            changes: [],
            audit: RuleBundleAudit(source: source, isVerified: verified, warnings: warnings))
    }

    private enum LocalSignature {
        case structured(BundleDocument.SigningDocument)
        case legacyDigest(String)
    }

    private static func loadLocalBundle() -> (data: Data, signature: LocalSignature)? {
        guard let supportDir = localBundleDirectoryURL() else { return nil }
        let bundleURL = supportDir.appendingPathComponent("rule-bundle.json")
        let signatureURL = supportDir.appendingPathComponent("rule-bundle.sig")

        guard
            let data = try? Data(contentsOf: bundleURL),
            let signatureText = try? String(contentsOf: signatureURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !signatureText.isEmpty
        else {
            return nil
        }

        if let structured = parseStructuredSignature(from: signatureText) {
            return (data, .structured(structured))
        }
        if isLikelyHexDigest(signatureText) {
            return (data, .legacyDigest(signatureText.lowercased()))
        }
        return nil
    }

    private static func localBundleDirectoryURL() -> URL? {
        if let explicitPath = UserDefaults.standard.string(forKey: SyncStoreKeys.ruleBundleDirectoryOverride),
           !explicitPath.isEmpty
        {
            return URL(fileURLWithPath: explicitPath, isDirectory: true)
        }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }

    private static func parseStructuredSignature(from text: String) -> BundleDocument.SigningDocument? {
        guard let data = text.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(BundleDocument.SigningDocument.self, from: data)
    }

    private static func isLikelyHexDigest(_ text: String) -> Bool {
        text.count == 64 && text.allSatisfy(\.isHexDigit)
    }

    private static func verify(
        document: BundleDocument,
        explicitSignature: LocalSignature?) -> (isVerified: Bool, warnings: [String])
    {
        let signatureInput: BundleDocument.SigningDocument?
        var warnings: [String] = []

        switch explicitSignature {
        case .none:
            signatureInput = document.signing
        case .structured(let structured):
            signatureInput = structured
        case .legacyDigest(let digest):
            let payload = canonicalPayloadData(from: document)
            let matchesDigest = validateDigest(data: payload, expectedHexDigest: digest)
            return (
                matchesDigest,
                matchesDigest
                    ? ["Legacy digest signature accepted. Re-sign with Ed25519 for future compatibility."]
                    : ["Legacy digest signature mismatch."])
        }

        guard let signatureInput else {
            return (false, ["Rule bundle is missing signing metadata."])
        }

        guard signatureInput.algorithm.lowercased() == "ed25519" else {
            return (false, ["Unsupported signature algorithm: \(signatureInput.algorithm)."])
        }

        guard let publicKeyB64 = trustedSigningKeys[signatureInput.keyID] else {
            return (false, ["Unknown signing key ID: \(signatureInput.keyID)."])
        }

        #if canImport(CryptoKit)
        guard
            let publicKeyRaw = Data(base64Encoded: publicKeyB64),
            let signatureRaw = Data(base64Encoded: signatureInput.signature),
            let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: publicKeyRaw)
        else {
            return (false, ["Rule bundle signature payload is malformed."])
        }

        let payload = canonicalPayloadData(from: document)
        let verified = publicKey.isValidSignature(signatureRaw, for: payload)
        if !verified {
            warnings.append("Rule bundle signature verification failed.")
        }
        return (verified, warnings)
        #else
        return (false, ["Signature verification unavailable on this platform."])
        #endif
    }

    private static func canonicalPayloadData(from document: BundleDocument) -> Data {
        struct CanonicalPayload: Encodable {
            let metadata: BundleDocument.MetadataDocument
            let changes: [BundleDocument.ChangeDocument]
        }

        let payload = CanonicalPayload(metadata: document.metadata, changes: document.changes)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return (try? encoder.encode(payload)) ?? Data()
    }

    private static func validateDigest(data: Data, expectedHexDigest: String) -> Bool {
        #if canImport(CryptoKit)
        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return hex == expectedHexDigest.lowercased()
        #else
        return false
        #endif
    }

    private static let trustedSigningKeys: [String: String] = [
        "release-2026-q1": "RxJQcCO8nvYngKjFfx0BAL7RJt8lA42u5BlckjErt+k=",
    ]

    private static let bundledJSON = """
    {
      "metadata": {
        "id": "us-rules",
        "displayName": "U.S. Catholic Fasting Rules",
        "version": "2026.3",
        "effectiveDate": "2026-01-01",
        "reviewedDate": "2026-02-11"
      },
      "changes": [
        {
          "date": "2026-02-11",
          "title": "Added explainability",
          "detail": "Each observance now includes rationale and source citations."
        },
        {
          "date": "2026-02-11",
          "title": "Added multi-state completion",
          "detail": "Tracking now supports completed, substituted, dispensed, and missed statuses."
        },
        {
          "date": "2026-02-11",
          "title": "Added safety guidance scenarios",
          "detail": "Food guidance now adapts to labor, travel, and medical-recovery contexts."
        },
        {
          "date": "2026-02-11",
          "title": "Hardened release integrity",
          "detail": "Rule bundle now uses Ed25519 signatures with trusted key IDs and audit warnings for invalid signatures."
        }
      ],
      "signing": {
        "key_id": "release-2026-q1",
        "algorithm": "ed25519",
        "signature": "DILY2O0Kdnj0jjYOdLa+5Q3k3XyV8ES8wkkIBvpbYOaKXWGVaQzmJhRavx8rsMsD/+4Whd0Lh/vxwtAyztN5Cw=="
      }
    }
    """
}
