@preconcurrency import Foundation

// swiftlint:disable nesting
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

        // swiftlint:enable nesting

        let metadata: MetadataDocument
        let changes: [ChangeDocument]
    }

    static func snapshot() -> BundleSnapshot {
        loadSnapshot()
    }

    private static func loadSnapshot() -> BundleSnapshot {
        var warningsFromLocal: [String] = []
        if let local = loadLocalBundle() {
            let evaluation = decodeBundleDocument(data: local)
            if let document = evaluation.document {
                return makeSnapshot(
                    from: document,
                    source: "local override",
                    verified: true,
                    warnings: evaluation.warnings)
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
        return makeSnapshot(
            from: bundledDocument,
            source: "bundled",
            verified: true,
            warnings: warningsFromLocal + bundledEvaluation.warnings)
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

    private static func loadLocalBundle() -> Data? {
        guard let supportDir = localBundleDirectoryURL() else { return nil }
        let bundleURL = supportDir.appendingPathComponent("rule-bundle.json")

        return try? Data(contentsOf: bundleURL)
    }

    private static func localBundleDirectoryURL() -> URL? {
        if let explicitPath = UserDefaults.standard.string(forKey: SyncStoreKeys.ruleBundleDirectoryOverride),
           !explicitPath.isEmpty
        {
            return URL(fileURLWithPath: explicitPath, isDirectory: true)
        }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }

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
          "title": "Added source audit",
          "detail": "Rule bundle metadata now includes source, review date, and fallback warnings."
        }
      ]
    }
    """
}
