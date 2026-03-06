import SwiftUI

struct MetricView: View {
    let title: String
    let value: String
    let unit: String
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    MetricView(title: "Hola", value: "12", unit: "24")
}
