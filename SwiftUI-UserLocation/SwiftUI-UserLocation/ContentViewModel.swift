//
//  ContentViewModel.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//

import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.331516,                                                                              longitude: -121.891054)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    
    //whenever this region changes our UI will update
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    
    @Published var coordinates: String = "0"
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            //checkLocationAuthorization()
            
        } else {
            print("Show an alert letting them know this is off and to go turn it on.")
        }
    }
    
private func checkLocationAuthorization(){
    guard let locationManager = locationManager else { return }
        
    switch locationManager.authorizationStatus {
            
        case .notDetermined:
            //switch to always in use?
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted likely due to parental controls")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
        //NOTE: not working with iPhone12 Pro and ProMax -> error:
        //Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            region = MKCoordinateRegion(center: locationManager.location!.coordinate,
                                    span: MapDetails.defaultSpan)
            coordinates = getCoordinatesString(coordinates2d: locationManager.location!.coordinate)
        @unknown default:
            break
        }

    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> String {
        return coordinates2d.latitude.description + ", " + coordinates2d.longitude.description
    }
}
