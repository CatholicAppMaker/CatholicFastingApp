import Foundation
import Testing

struct SacredImageryAssetTests {
    @Test func activeSacredGalleryUsesStrongResolvableAssets() throws {
        let root = repoRoot()
        let source = try String(contentsOf: root.appendingPathComponent("CatholicFastingApp/AppSacredVisuals.swift"), encoding: .utf8)
        let gallerySource = try source.slice(from: "static let fastingGallery", through: "    ]")
        let assetNames = gallerySource.matches(for: #"assetName: "([^"]+)""#)

        #expect(assetNames.count >= 18)
        #expect(Set(assetNames).count == assetNames.count)
        #expect(!assetNames.contains { $0.hasPrefix("SacredConcept") })

        let assetsRoot = root.appendingPathComponent("CatholicFastingApp/Assets.xcassets")
        for assetName in assetNames {
            let imageset = assetsRoot.appendingPathComponent("\(assetName).imageset")
            let contentsURL = imageset.appendingPathComponent("Contents.json")
            #expect(FileManager.default.fileExists(atPath: contentsURL.path), "Missing Contents.json for \(assetName)")

            let data = try Data(contentsOf: contentsURL)
            let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let images = object?["images"] as? [[String: Any]] ?? []
            let filenames = images.compactMap { $0["filename"] as? String }
            #expect(!filenames.isEmpty, "Missing bitmap filename for \(assetName)")
            for filename in filenames {
                #expect(FileManager.default.fileExists(atPath: imageset.appendingPathComponent(filename).path), "Missing \(filename) for \(assetName)")
            }
        }
    }

    @Test func archivedConceptSacredAssetsAreNotReferencedByAppSource() throws {
        let root = repoRoot()
        let appRoot = root.appendingPathComponent("CatholicFastingApp")
        let swiftFiles = FileManager.default.enumerator(at: appRoot, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" } ?? []

        let conceptReferences = try swiftFiles.flatMap { file -> [String] in
            let source = try String(contentsOf: file, encoding: .utf8)
            guard source.contains("SacredConcept") else { return [] }
            return [file.lastPathComponent]
        }

        #expect(conceptReferences.isEmpty, "Archived concept assets still referenced by: \(conceptReferences.joined(separator: ", "))")
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

private extension String {
    func slice(from start: String, through end: String) throws -> String {
        guard let startRange = range(of: start) else {
            throw SacredImageryTestError.missingMarker(start)
        }
        let remainder = self[startRange.lowerBound...]
        guard let endRange = remainder.range(of: end) else {
            throw SacredImageryTestError.missingMarker(end)
        }
        return String(remainder[..<endRange.upperBound])
    }

    func matches(for pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(startIndex..., in: self)
        return regex.matches(in: self, range: range).compactMap { match in
            guard match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: self) else { return nil }
            return String(self[range])
        }
    }
}

enum SacredImageryTestError: Error {
    case missingMarker(String)
}
