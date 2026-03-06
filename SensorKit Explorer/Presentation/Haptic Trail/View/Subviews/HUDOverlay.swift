import SwiftUI

//extension Date {
//    var
//}

struct HUDOverlay: View {
    let cadence: Double
    let distance: Double
    let startDate: Date?
    var body: some View {
        HStack(spacing: 16) {
            MetricView(
                title: "Cadence",
                value: String(format: "%.2f", cadence),
                unit: "steps/s"
            )
            MetricView(
                title: "Distance",
                value: String(format: "%.0f", distance),
                unit: "m"
            )
            if let startDate {
                TimelineView(.periodic(from: startDate, by: 1)) { context in
                    MetricView(
                        title: "Time",
                        value: formatTime(context.date.timeIntervalSince(startDate)),
                        unit: ""
                    )
                }
            } else {
                MetricView(
                    title: "Time",
                    value: "00:00",
                    unit: ""
                )
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time)
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}

#Preview {
    HUDOverlay(cadence: 12.2, distance: 45.2, startDate: nil)
}
