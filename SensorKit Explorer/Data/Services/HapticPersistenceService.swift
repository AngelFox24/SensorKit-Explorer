import Foundation

protocol HapticPersistenceServiceProtocol {
    func save(patterns: [HapticPatternModel])
    func load() -> [HapticPatternModel]
    func exportPattern(_ pattern: HapticPatternModel) throws -> URL
}

final class HapticPersistenceService: HapticPersistenceServiceProtocol {
    private let filename = "hapticPatterns.json"
    
    func save(patterns: [HapticPatternModel]) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else { return }
        try? JSONEncoder().encode(patterns).write(to: url)
    }
    
    func load() -> [HapticPatternModel] {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename),
              let data = try? Data(contentsOf: url),
              let patterns = try? JSONDecoder().decode([HapticPatternModel].self, from: data) else { return [] }
        return patterns
    }
    
    func exportPattern(_ pattern: HapticPatternModel) throws -> URL {
        guard let jsonData = try? JSONEncoder().encode(pattern) else {
            throw HapticsServiceError.exportFailure
        }
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(pattern.id).ahap")
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            throw HapticsServiceError.underlying(error)
        }
    }
}
