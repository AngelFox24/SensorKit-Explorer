import Foundation

protocol LocationServiceProtocol {
    func locationStream() -> AsyncThrowingStream<Coordinates, Error>
}
