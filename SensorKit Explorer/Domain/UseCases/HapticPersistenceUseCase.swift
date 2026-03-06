import Foundation

struct HapticPersistenceUseCase {
    private let hapticsPersistenceService: HapticPersistenceServiceProtocol
    private let maxSavedPatterns: Int = 5
    init(
        hapticsPersistenceService: HapticPersistenceServiceProtocol
    ) {
        self.hapticsPersistenceService = hapticsPersistenceService
    }
    
    func save(patterns: [HapticPatternModel]) {
        let loadPatters = self.load()
        let combined = patterns + loadPatters
        let toSave: [HapticPatternModel] = Array(combined.prefix(maxSavedPatterns))
        hapticsPersistenceService.save(patterns: toSave)
    }
    func load() -> [HapticPatternModel] {
        hapticsPersistenceService.load()
    }
    func exportPattern(_ pattern: HapticPatternModel) throws -> URL {
        try hapticsPersistenceService.exportPattern(pattern)
    }
}
