import Foundation

struct HapticPatternModel: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    
    var intensity: Double
    var sharpness: Double
    var duration: Double
    var attackTime: Double
    var decayTime: Double
    var sustained: Bool
    var createdAt: Date?
}

extension HapticPatternModel {
    var createdAtString: String {
        guard let createdAt else { return id.uuidString }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: createdAt)
    }
}
