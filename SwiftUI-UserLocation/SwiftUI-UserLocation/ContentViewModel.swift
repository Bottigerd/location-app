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

struct Response: Decodable {
    let results: [Component]
    let status: String

    struct Component: Decodable {
        let address_components: [Address]
        let formatted_address: String
        let geometry: Geometry
        let place_id: String
        let plus_code: PlusCode?
        let types: [String]
    }

    struct Address: Decodable {
        let long_name: String
        let short_name: String
        let types : [String]
    }

    struct Geometry: Decodable {
        let location: Location
        let location_type: String
        let viewport: Viewport
    }

    struct Viewport: Decodable {
        let northeast: Location
        let southwest: Location
    }

    struct PlusCode: Decodable {
        let compound_code: String
        let global_code: String
    }

    struct Location: Decodable {
        let lat: Float
        let lng: Float
    }
}

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    
    //whenever this region changes our UI will update
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    
    @Published var coordinates: String = "0"
    
    var API_KEY: String = "0"
    
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
        getLocationName()
        @unknown default:
            break
        }

    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> String {
        return coordinates2d.latitude.description + "," + coordinates2d.longitude.description
    }
    
    func getLocationName(){
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + coordinates + "&location_type=ROOFTOP&result_type=street_address&key=" + API_KEY) else{return}
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            
            
            let decoder = JSONDecoder()

//                    if let data = data{
//                        do{
//                            let tasks = try decoder.decode([Response].self, from: data)
//                            tasks.forEach{ i in
//                                print(i.status)
//                            }
//                        }catch{
//                            print(error)
//                        }
//                    }
            
            if let data = data, let string = String(data: data, encoding: .utf8){
                print(string)
            }
            
        }
        task.resume()
    }
    
}





