import SwiftUI
import MapKit

extension Coordinates {
    var latitudeLocation: CLLocationDegrees {
        return CLLocationDegrees(latitude)
    }
    var longitudeLocation: CLLocationDegrees {
        return CLLocationDegrees(longitude)
    }
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitudeLocation, longitude: longitudeLocation)
    }
}

extension Array where Element == Coordinates {
    func toCLLocationCoordinate2DArray() -> [CLLocationCoordinate2D] {
        return self.map({$0.clLocationCoordinate2D})
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    var coordinates: [Coordinates]
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        guard coordinates.count > 1 else { return }
        let polyline = MKPolyline(coordinates: coordinates.toCLLocationCoordinate2DArray(), count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
