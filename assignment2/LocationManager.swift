import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.60775375366211, longitude: -79.66155242919922),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        } else {
            print("Show an alert letting them know this is off and to go turn it on.")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Your location is restricted likely due to parental control.")
            case .denied:
                print("You have denied this app location permission. Go into settings to change it.")
            case .authorizedAlways, .authorizedAlways:
                region = MKCoordinateRegion(
                    center: locationManager.location!.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            @unknown default:
                break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
}
