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

struct Response: Codable {
    let plusCode: PlusCode
    let results: [Result]
    let status: String

    enum CodingKeys: String, CodingKey {
        case plusCode = "plus_code"
        case results, status
    }
}

struct PlusCode: Codable {
    let compoundCode, globalCode: String

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}

struct Result: Codable {
    let addressComponents: [AddressComponent]
    let formattedAddress: String
    let geometry: Geometry
    let placeID: String
    let plusCode: PlusCode
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case geometry
        case placeID = "place_id"
        case plusCode = "plus_code"
        case types
    }
}

struct AddressComponent: Codable {
    let longName, shortName: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

struct Geometry: Codable {
    let location: Location
    let locationType: String
    let viewport: Viewport

    enum CodingKeys: String, CodingKey {
        case location
        case locationType = "location_type"
        case viewport
    }
}

struct Location: Codable {
    let lat, lng: Double
}

struct Viewport: Codable {
    let northeast, southwest: Location
}

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    
    //whenever this region changes our UI will update
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    
    @Published var coordinates: String = "0"
    
    @Published var location: String = "Pending Location"
    
    // DO NOT PUSH WITH THIS FILLED
    var API_KEY: String = ""
    
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
            print("location is restricted likely due to parental controls")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
        //NOTE: not working with iPhone12 Pro and ProMax -> error:
        //Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? MapDetails.startingLocation,
                                 span: MapDetails.defaultSpan)
            coordinates = getCoordinatesString(coordinates2d: locationManager.location?.coordinate ?? MapDetails.startingLocation)
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
    
    func getLocationName() {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + coordinates + "&location_type=ROOFTOP&result_type=street_address&key=" + API_KEY)
        else{
            print("ERROR: Malformed Request")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let tasks = try decoder.decode(Response.self, from: data)
                    self.location = tasks.results[0].formattedAddress
                } catch {
                    print("ERROR: Could not decode JSON response")
                }
            }
            
            // print JSON for testing purposes
            if let data = data, let string = String(data: data, encoding: .utf8){
                print(string)
            }
            
        }
        task.resume()
    }
    
}





