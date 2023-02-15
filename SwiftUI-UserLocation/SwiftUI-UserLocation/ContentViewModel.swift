//
//  ContentViewModel.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//

import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 44.460505,                                                                              longitude: -93.156647)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

/*
 MARK: - STRUCTS
 */
// MARK: - ReverseGeoCodingResponseStruct
struct ReverseGeoCodingResponseStruct: Codable {
    let plusCode: PlusCodeStruct?
    let results: [ReverseGeoCodingResult]?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case plusCode = "plus_code"
        case results, status
    }
}

struct PlusCodeStruct: Codable {
    let compoundCode, globalCode: String
    
    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}

struct ReverseGeoCodingResult: Codable {
    let addressComponents: [AddressComponentStruct]
    let formattedAddress: String
    let geometry: GeometryStruct
    let placeID: String
    let plusCode: PlusCodeStruct
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

struct AddressComponentStruct: Codable {
    let longName, shortName: String
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

struct GeometryStruct: Codable {
    let location: LocationStruct
    let locationType: String
    let viewport: ViewportStruct
    
    enum CodingKeys: String, CodingKey {
        case location
        case locationType = "location_type"
        case viewport
    }
}

struct LocationStruct: Codable {
    let lat, lng: Double
}

struct ViewportStruct: Codable {
    let northeast, southwest: LocationStruct
}

/*
 MARK: - PlaceResponseStruct
 */

struct PlaceResponseStruct: Codable {
    let result: PlaceResult
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case result, status
    }
}

// MARK: - Result
struct PlaceResult: Codable {
    let name: String
}

// MARK: - Config Reader

private struct ConfigStruct: Codable {
    let api_key: String
}

private class Config {
    private var config: ConfigStruct?
    
    init(fileName: String){
        print("Initilize Config")
        let json_raw = readJSONfile(name: fileName)
        if (json_raw != nil){
            config = parse(jsonData: json_raw!) ?? ConfigStruct(api_key: "")
        } else {
            config = ConfigStruct(api_key: "")
        }
        
    }
    
    private func readJSONfile(name: String) -> Data? {
        print("Read Config")
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    private func parse(jsonData: Data) -> ConfigStruct? {
        print("Parse Config")
        do {
            let decodedData = try JSONDecoder().decode(ConfigStruct.self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    func get_api_key() -> String {
        return config?.api_key ?? ""
    }
}

/*
 MARK: - CONTENT VIEW MODEL
 */

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    // MARK: - Important Variables
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    @Published var address = "Pending Location"
    private var config = Config(fileName: "config")
    var previous_coordinates = MapDetails.startingLocation
    
    // API Responses (URLSession discards response before completion, so we save to a class variable
    var reverse_geo_code_results: ReverseGeoCodingResponseStruct?
    var place_results: PlaceResponseStruct?
    var locationManager: CLLocationManager?
    
    // Checks for locaiton permissions, sets up location manager if true
    func setupLocationManager() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager!.distanceFilter = 50; // Distance in meters, trigger for location update
            return true
            
        } else {
            print("Show an alert letting them know this is off and to go turn it on.")
            return false
        }
    }
    
    func startUpdatingLocation(){
        let locServicesEnabled = setupLocationManager()
        let locServicesValidType = checkLocationAuthorizationType()
        if (locServicesEnabled && locServicesValidType){
            locationManager?.startUpdatingLocation()
        }
    }
    
    /*
     Handles automated location updating, uses distance filter set up in setupLocationManager
     */
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let coordinates = fetchCoordinates()
        region = MKCoordinateRegion(center: coordinates,
                                    span: MapDetails.defaultSpan)
        updateAddress(coordinates: coordinates)
    }
    
    // MARK: - Location Functions
    func checkLocationAuthorizationType() -> Bool {
        guard let locationManager = locationManager else { return false }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false
        case .restricted:
            print("location is restricted likely due to parental controls")
            return false
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            break
        }
        return false
    }
    
    /*
     Fetches new location and updates the location display with the new information.
     Public so it can be called from ContentView
     */
    func updateDisplay(){
        let coordinates = fetchCoordinates()
        region = MKCoordinateRegion(center: coordinates,
                                    span: MapDetails.defaultSpan)
        updateAddress(coordinates: coordinates)
    }
    
    // gets updated coordinates from location manager, also updates mapview.
    func fetchCoordinates() -> CLLocationCoordinate2D {
        // if locationManager fails to get location, revert to previously fetched coordinates
        let coordinates = locationManager?.location?.coordinate ?? previous_coordinates
        previous_coordinates = coordinates
        return coordinates
    }
    
    // using location manager coordinates, updates displayed address
    private func updateAddress(coordinates: CLLocationCoordinate2D) {
        let coordinates_string = getCoordinatesString(coordinates2d: coordinates)
        var temp_address: String?
        
        let globalQueue = DispatchQueue.global()
        globalQueue.sync {
            getReverseGeocode(coordinates: coordinates_string)
        }
        if (reverse_geo_code_results?.status == "OK") {
            let place_id = reverse_geo_code_results?.results?[0].placeID ?? nil
            temp_address = reverse_geo_code_results?.results?[0].formattedAddress
            
            if (place_id != nil) {
                globalQueue.sync {
                    getPlace(place_id: place_id!)
                }
                if (place_results?.status == "OK"){
                    temp_address = getPlaceName()
                }
                
            }
        }
        address = temp_address ?? "Pending Location"
        
    }
    
    // returns coordinates from a CLLocationCoordinate2D as a string for API usage
    internal func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> String {
        return coordinates2d.latitude.description + "," + coordinates2d.longitude.description
    }
    
    internal func getPlaceName() -> String {
        let place_name = place_results!.result.name
        var locality = ""
        var admin_area_1 = ""
        var postal_code = ""
        var country = ""
        
        for address_component in reverse_geo_code_results!.results![0].addressComponents {
            if (address_component.types.contains("locality")) {
                locality = address_component.longName
            } else if (address_component.types.contains("administrative_area_level_1")) {
                admin_area_1 = address_component.shortName
            } else if (address_component.types.contains("postal_code")) {
                postal_code = address_component.shortName
            } else if (address_component.types.contains("country")) {
                country = address_component.shortName
            }
        }
        
        /*
         It's weird to split this up, I know, but it was occassionally causing this error:
         The compiler is unable to type-check this expression in reasonable time;
         try breaking up the expression into distinct sub-expressions.
         */
        let full_name_pt1 = place_name + ", " + locality + ", " + admin_area_1
        let full_name_pt2 = " " + postal_code + ", " + country
        return full_name_pt1 + full_name_pt2
    }
    
    // MARK: - API Calls
    
    // MARK: - Reverse Geocoding API
    // transforms the json from the reverse geocoding API call into a struct for referencing
    internal func getReverseGeocode(coordinates: String) {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + coordinates + "&location_type=ROOFTOP&result_type=street_address&key=" + config.get_api_key())
        else{
            print("ERROR: Malformed Request (GET REVERSE GEOCODE)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let reverse_geo_code_struct = try decoder.decode(ReverseGeoCodingResponseStruct.self, from: data)
                    DispatchQueue.main.sync {
                        self.reverse_geo_code_results = reverse_geo_code_struct
                    }
                } catch {
                    print("ERROR: Could not decode JSON response (GET REVERSE GEOCODE)")
                    return
                }
            }
            
            print("REVERSE GEOCODING API CALL: " + coordinates)
            
            /*
             // print JSON for testing purposes
             if let data = data, let string = String(data: data, encoding: .utf8){
             print(string)
             }
             */
            
            
        }
        task.resume()
    }
    
    // MARK: - Places API
    internal func getPlace(place_id: String) {
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id="
                            + place_id + "&fields=name%2Crating%2Cformatted_phone_number&key=" + config.get_api_key())
        else{
            print("ERROR: Malformed Request (GET PLACE)")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let place_struct = try decoder.decode(PlaceResponseStruct.self, from: data)
                    DispatchQueue.main.sync {
                        self.place_results = place_struct
                    }
                } catch {
                    print("ERROR: Could not decode JSON response (GET PLACE)")
                }
            }
            
            print("PLACE API CALL: " + place_id)
            /*
             // print JSON for testing purposes
             if let data = data, let string = String(data: data, encoding: .utf8){
             print(string)
             }
             */
            
        }
        task.resume()
    }
    
}





