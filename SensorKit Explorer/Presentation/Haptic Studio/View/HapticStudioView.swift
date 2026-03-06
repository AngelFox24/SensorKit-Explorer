import SwiftUI
import UniformTypeIdentifiers

struct HapticStudioView: View {
    @State private var viewModel: HapticStudioViewModel
    init(container: DIContainer) {
        self._viewModel = State(initialValue: HapticStudioViewModelBuilder.getViewModel(container: container))
    }
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Haptic Parameters")) {
                    VStack(alignment: .leading) {
                        Text("Intensity: \(String(format: "%.2f", viewModel.intensity))")
                        Slider(value: $viewModel.intensity, in: 0...1)
                    }
                    VStack(alignment: .leading) {
                        Text("Sharpness: \(String(format: "%.2f", viewModel.sharpness))")
                        Slider(value: $viewModel.sharpness, in: 0...1)
                    }
                    VStack(alignment: .leading) {
                        Text("Duration: \(String(format: "%.2f", viewModel.duration)) sec")
                        Slider(value: $viewModel.duration, in: 0...5)
                    }
                    VStack(alignment: .leading) {
                        Text("Attack Time: \(String(format: "%.2f", viewModel.attackTime)) sec")
                        Slider(value: $viewModel.attackTime, in: 0...1)
                    }
                    VStack(alignment: .leading) {
                        Text("Decay Time: \(String(format: "%.2f", viewModel.decayTime)) sec")
                        Slider(value: $viewModel.decayTime, in: 0...1)
                    }
                    Toggle("Sustained", isOn: $viewModel.sustained)
                }
                Section(header: Text("Envelope Chart")) {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height: CGFloat = 100
                        let duration = max(viewModel.duration, 0.0001)
                        let attackTimeClamped = min(viewModel.attackTime, duration)
                        let decayTimeClamped = min(viewModel.decayTime, duration - attackTimeClamped)
                        let sustainWidth = max(width - (attackTimeClamped + decayTimeClamped) / duration * width, 0)
                        let attackWidth = (attackTimeClamped / duration) * width
                        let intensityHeight = CGFloat(viewModel.intensity) * height
                        
                        Path { path in
                            if viewModel.sustained {
                                // attack → sustain → decay curve
                                path.move(to: CGPoint(x: 0, y: height))
                                path.addLine(to: CGPoint(x: attackWidth, y: height - intensityHeight))
                                path.addLine(to: CGPoint(x: attackWidth + sustainWidth, y: height - intensityHeight))
                                path.addLine(to: CGPoint(x: width, y: height))
                            } else {
                                // single transient spike
                                let spikeWidth = width * 0.1
                                path.move(to: CGPoint(x: 0, y: height))
                                path.addLine(to: CGPoint(x: spikeWidth / 2, y: height - intensityHeight))
                                path.addLine(to: CGPoint(x: spikeWidth, y: height))
                                path.addLine(to: CGPoint(x: width, y: height))
                            }
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(height: height)
                    }
                    .frame(height: 100)
                }
                Section {
                    Button("Preview") {
                        viewModel.preview()
                    }
                }
                Section {
                    Button("Save") {
                        viewModel.saveCurrentPattern()
                    }
                }
                Section(header: Text("Saved Patterns")) {
                    List {
                        ForEach(viewModel.savedPatterns, id: \.self) { pattern in
                            Button {
                                viewModel.viewSavedPatterns(id: pattern.id)
                            } label: {
                                Text(pattern.createdAtString)
                            }
                        }
                    }
                }
                Section {
                    Button("Export") {
                        viewModel.exportAhap()
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $viewModel.showExporter,
            document: viewModel.fileToExport,
            contentTypes: [.json],
            defaultFilename: "pattern.ahap"
        ) { result in
            switch result {
            case .success(let url): print("Exported to \(url)")
            case .failure(let error): print("Export failed: \(error)")
            }
        }
        .task {
            self.viewModel.loadSavedPatterns()
        }
    }
}

#Preview {
    HapticStudioView(container: DIContainer())
}
