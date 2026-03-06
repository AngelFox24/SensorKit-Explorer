import Foundation

@Observable
final class HapticStudioViewModel {
    var intensity: Double = 0.5
    var sharpness: Double = 0.5
    var duration: Double = 1.0
    var attackTime: Double = 0.0
    var decayTime: Double = 0.0
    var sustained: Bool = true
    var savedPatterns: [HapticPatternModel] = []
    var showExporter = false
    var fileToExport: HapticPatternFile?
    private var pattern: HapticPatternModel {
        HapticPatternModel(
            intensity: intensity,
            sharpness: sharpness,
            duration: duration,
            attackTime: attackTime,
            decayTime: decayTime,
            sustained: sustained
        )
    }
    //Use cases
    private let hapticUseCase: EmitHapticUseCase
    private let hapticPersistenceUseCase: HapticPersistenceUseCase
    init(
        hapticUseCase: EmitHapticUseCase,
        hapticPersistenceUseCase: HapticPersistenceUseCase
    ) {
        print("[HapticStudioViewModel] init.")
        self.hapticUseCase = hapticUseCase
        self.hapticPersistenceUseCase = hapticPersistenceUseCase
    }
    func preview() {
        do {
            try self.hapticUseCase.play(pattern: pattern)
        } catch {
            print("[HapticStudioViewModel] play error: \(error)")
        }
    }
    func viewSavedPatterns(id: UUID) {
        guard let pattern = savedPatterns.first(where: { $0.id == id }) else { return }
        self.intensity = pattern.intensity
        self.sharpness = pattern.sharpness
        self.duration = pattern.duration
        self.attackTime = pattern.attackTime
        self.decayTime = pattern.decayTime
        self.sustained = pattern.sustained
    }
    func saveCurrentPattern() {
        let model = HapticPatternModel(
            intensity: intensity,
            sharpness: sharpness,
            duration: duration,
            attackTime: attackTime,
            decayTime: decayTime,
            sustained: sustained,
            createdAt: Date()
        )
        savedPatterns.insert(model, at: 0)
        if savedPatterns.count > 5 { savedPatterns.removeLast() }
        persistPatterns()
    }
    
    func persistPatterns() {
        self.hapticPersistenceUseCase.save(patterns: savedPatterns)
    }
    
    func loadSavedPatterns() {
        self.savedPatterns = self.hapticPersistenceUseCase.load()
    }
    
    func exportAhap() {
        if let patternData = try? JSONEncoder().encode(pattern) {
            fileToExport = HapticPatternFile(patternData: patternData)
            showExporter = true
        }
    }
}
