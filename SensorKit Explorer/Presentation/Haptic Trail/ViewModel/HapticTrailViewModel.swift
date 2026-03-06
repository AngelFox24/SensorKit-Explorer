import Foundation

@Observable
final class HapticTrailViewModel {
    var coordinates: [Coordinates] = []
    var cadence: Double = 0.0
    var distance: Double = 0
    var startDate: Date?
    var isStarted: Bool = false
    //Private
    private let minimumDistanceToAppend: Double = 10.0
    private var streamsTask: Task<Void, Never>? = nil
    //Use cases
    private let locationUseCase: ObserveDeviceLocationUseCase
    private let hapticUseCase: EmitHapticUseCase
    private let pedometerUseCase: PedometerServiceUseCase
    
    init(
        locationUseCase: ObserveDeviceLocationUseCase,
        hapticUseCase: EmitHapticUseCase,
        pedometerUseCase: PedometerServiceUseCase
    ) {
        self.locationUseCase = locationUseCase
        self.hapticUseCase = hapticUseCase
        self.pedometerUseCase = pedometerUseCase
    }
    func evaluateStart() {
        if streamsTask == nil && self.isStarted {
            streamsTask = Task {
                await self.startStreams()
            }
        }
    }
    func stopStreams() {
        self.isStarted = false
        streamsTask?.cancel()
        streamsTask = nil
    }
    private func startStreams() async {
        self.startTimer()
        defer { endTimer() }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                await self?.startPedometerStream()
            }
            group.addTask { [weak self] in
                await self?.startLocationStream()
            }
        }
    }
    @MainActor
    private func startTimer() {
        self.startDate = Date()
    }
    @MainActor
    private func endTimer() {
        self.startDate = nil
    }
    private func startPedometerStream() async {
        do {
            for try await cadence in pedometerUseCase.cadenceStream() {
                self.setCadence(cadence)
            }
        } catch {
            
        }
    }
    private func startLocationStream() async {
        do {
            for try await location: Coordinates in locationUseCase.execute() {
                print("[HapticTrailViewModel] NewPoint: \(location.longitude)")
                if shouldAppend(location) {
                    self.appendCoordinate(location)
                }
            }
        } catch {
            print("[HapticTrailViewModel] Error: \(error)")
        }
    }
    @MainActor
    private func setCadence(_ cadence: Double) {
        self.cadence = cadence
    }

    private func shouldAppend(_ newLocation: Coordinates) -> Bool {
        guard let last = coordinates.last else { return true }
        let distance = newLocation.distance(from: last)
        return distance >= minimumDistanceToAppend
    }
    @MainActor
    private func appendCoordinate(_ newCoordinate: Coordinates) {
        if coordinates.count >= 30 {
            self.coordinates.removeFirst()
        }
        self.hapticUseCase.executeStrong()
        if let last = coordinates.last {
            distance += newCoordinate.distance(from: last)
        }
        self.coordinates.append(newCoordinate)
    }
    
    func toggleActivity() {
        self.isStarted.toggle()
        if self.isStarted {
            self.evaluateStart()
        } else {
            self.stopStreams()
        }
    }
}
