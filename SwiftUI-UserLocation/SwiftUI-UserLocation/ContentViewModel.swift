//
//  ContentViewModel.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//

import MapKit
import CoreData


extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

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
        let jsonRAW = readJSONfile(name: fileName)
        if (jsonRAW != nil){
            config = parse(jsonData: jsonRAW!) ?? ConfigStruct(api_key: "")
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
    
    func getApiKey() -> String {
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
    var previousCoordinates = MapDetails.startingLocation
    // API Responses (URLSession discards response before completion, so we save to a class variable
    var reverseGeoCodeResults: ReverseGeoCodingResponseStruct?
    var placeResults: PlaceResponseStruct?
    var locationManager: CLLocationManager?

    //    map from place id to Carleton Buildings
    var carletonDict:[String:String] = [
        "ChIJDa9m6rdT9ocReWbwDkfk7YU" : "Severance Hall / Burton Hall",
        "ChIJc61YtLdT9ocR7Cr5WtVvW_g" : "Laird Stadium / Facilities Building / West Gym",
        "ChIJTZQLpbdT9ocRqvqVtggIPhs" : "Willis Hall / Sayles",
        "ChIJZQ1g8bdT9ocRjAlA8KvQSok" : "Davis Hall",
        "ChIJp7q2lLdT9ocRHBsYjwG9ceE" : "Scoville Hall",
        "ChIJ73W88LdT9ocRVeBRJm1aCU4" : "Musser Hall",
        "ChIJveYnVbZT9ocRUeG2LmtNKYQ" : "Leighton Hall",
        "ChIJV7Vl37ZT9ocRdKyoCrESLHQ" : "Laurence McKiny Gould Library",
        "ChIJI7Ide7dT9ocR8-ZMITh6qAs" : "Skinner Memorial Chapel",
        "ChIJV2kfO7dT9ocRkLNf1wMNvDc" : "The Bold Spot",
        "ChIJjdlF_jhT9ocRB2WNC8wfu8E" : "Center for Mathematics and Computing",
        "ChIJj58vk7RT9ocRAo2NbglMiRs" : "Boliou Hall",
        "ChIJM9HO1rBT9ocRE7KzwWT4BTM" : "Goodsell Observatory",
        "ChIJqXjdzLBT9ocRiyR1NFp_or8" : "Olin Hall of Science / Hulings Hall / Anderson",
        "ChIJ4wZEyLBT9ocRsuHGwEZEKDw" : "Norse Hall",
        "ChIJEY7-k45T9ocR6zi3hMMKCXw" : "Ardis and Robert James Hall / Casset Hall",
        "ChIJhzudb7BT9ocRWxttpsHoQ_4" : "Myers Hall / The Cave at Carleton College",
        "ChIJ90cSh7pT9ocRRWLkRdbBxnA" : "Watson Hall / Cowling Gymnasium",
        "ChIJ35h_jrFT9ocRF_dYcIPXW5k" : "Goodhue Hall / Recreration Center at Carleton College",
        "ChIJpw728LhT9ocRurmgIi9AE8k" : "Weitz Center for creativity",
        "ChIJD5D9yrdT9ocRe9yS44RH-68" : "Allen House",
        "ChIJQ2q6D8hT9ocRhyqPEyfnGIs" : "Wilson House",
        "ChIJTzVZBshT9ocRXih5mEYdNR8" : "Prentice House",
        "ChIJnyIJxrBT9ocRyiDLmcJrhSc" : "Language and Dining Center"
        ]

    var viewContext = PersistenceController.shared.container.viewContext
    
    // Checks for locaiton permissions, sets up location manager if true
    func setupLocationManager() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.distanceFilter = 50 // Distance in meters, trigger for location update
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
        let accuracy = locationManager?.location?.horizontalAccuracy
        let coordinates = fetchCoordinates()
        updateMapRegion(coordinates: coordinates)
        if (accuracy! <= 10.0) { // Only call API if accuracy is high enough; within 10 meters
            print("\nUpdating Location")
            updateDisplay(coordinates: coordinates)
        }
        
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
    
    func updateMapRegion(coordinates: CLLocationCoordinate2D){
        region = MKCoordinateRegion(center: coordinates,
                                    span: MapDetails.defaultSpan)
    }
    
    /*
     Fetches new location and updates the location display with the new information.
     Public so it can be called from ContentView.
     */
    func updateDisplay(coordinates: CLLocationCoordinate2D){
        callLocationAPIs(coordiantes: coordinates)
        let apiDelaySeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + apiDelaySeconds) {
            // Waiting... (to let API calls and JSON decoder finish
            let placeName = self.updateAddress(coordinates: coordinates)
            if (placeName != "Pending Location" && !placeName.contains("No address at ")) {
                // don't send to core data if there's no address
                self.addToCoreData(coordinates: coordinates, placeName: placeName)
            }
        }
    }
    
    // gets updated coordinates from location manager, also updates mapview.
    func fetchCoordinates() -> CLLocationCoordinate2D {
        // if locationManager fails to get location, revert to previously fetched coordinates
        let coordinates = locationManager?.location?.coordinate ?? previousCoordinates
        previousCoordinates = coordinates
        return coordinates
    }
    
    
    // calls reverse geocoding api and places api if applicable,
    private func callLocationAPIs(coordiantes: CLLocationCoordinate2D) {
        let coordinatesString = getCoordinatesString(coordinates2d: coordiantes)
        getReverseGeocode(coordinates: coordinatesString)
        
        let status = reverseGeoCodeResults?.status
        if (status == "OK") {
            let placeId = reverseGeoCodeResults?.results?[0].placeID ?? nil
            if (placeId != nil) {
                getPlace(placeId: placeId!)
            }
        }
    }
    
    // using location manager coordinates, updates displayed address
    private func updateAddress(coordinates: CLLocationCoordinate2D) -> String {
        var tempAddress: String?
        
        let status = reverseGeoCodeResults?.status
        if (status == "OK") {
            let placeId = reverseGeoCodeResults?.results?[0].placeID ?? nil
            tempAddress = reverseGeoCodeResults?.results?[0].formattedAddress
            
            if (placeId != nil) {
                if (self.carletonDict[placeId!] != nil){
                    let carletonBuilding = self.carletonDict[placeId!]
                    tempAddress = carletonBuilding! + ", Carleton College, Northfield, MN 55057 USA"
                } else {
                    getPlace(placeId: placeId!)
                    if (placeResults?.status == "OK"){
                            tempAddress = getPlaceName()
                        }
                }
                
            }
        } else if (status == "ZERO_RESULTS"){
            let coordinateString = String(coordinates.latitude) + ", " + String(coordinates.longitude)
            tempAddress = "No address at " + coordinateString
        }
        
        address = tempAddress ?? "Pending Location"
        return address // returned value gets added to coreData
        
    }
    
    internal func addToCoreData(coordinates: CLLocationCoordinate2D, placeName: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        addLocationFromAPI(givenTime: Date(), givenLat: coordinates.latitude, givenLong: coordinates.longitude, givenAlt: 0, givenName: placeName)
    }
    
    // returns coordinates from a CLLocationCoordinate2D as a string for API usage
    internal func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> String {
        return coordinates2d.latitude.description + "," + coordinates2d.longitude.description
    }
    
    internal func getPlaceName() -> String {
        let placeName = placeResults!.result.name
        var locality = ""
        var AdminArea1 = ""
        var postalCode = ""
        var country = ""
        
        for addressComponent in reverseGeoCodeResults!.results![0].addressComponents {
            if (addressComponent.types.contains("locality")) {
                locality = addressComponent.longName
            } else if (addressComponent.types.contains("administrative_area_level_1")) {
                AdminArea1 = addressComponent.shortName
            } else if (addressComponent.types.contains("postalCode")) {
                postalCode = addressComponent.shortName
            } else if (addressComponent.types.contains("country")) {
                country = addressComponent.shortName
            }
        }
        
        /*
         It's weird to split this up, I know, but it was occassionally causing this error:
         The compiler is unable to type-check this expression in reasonable timel
         try breaking up the expression into distinct sub-expressions.
        */
        let fullNamePt1 = placeName + ", " + locality + ", " + AdminArea1
        let fullNamePt2 = " " + postalCode + ", " + country
        return fullNamePt1 + fullNamePt2
    }
    
    // MARK: - API Calls
    
    // MARK: - Reverse Geocoding API
    // transforms the json from the reverse geocoding API call into a struct for referencing
    internal func getReverseGeocode(coordinates: String) {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + coordinates + "&location_type=ROOFTOP&result_type=street_address&key=" + config.getApiKey())
        else{
            print("ERROR: Malformed Request (GET REVERSE GEOCODE)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let reverseGeoCodeStruct = try decoder.decode(ReverseGeoCodingResponseStruct.self, from: data)
                    self.reverseGeoCodeResults = reverseGeoCodeStruct
                } catch {
                    print("ERROR: Could not decode JSON response (GET REVERSE GEOCODE)")
                    return
                }
            }
            
            print("REVERSE GEOCODING API CALL: " + coordinates)
            
            /*
            // print formatted address for testing purposes
            if (self.reverseGeoCodeResults?.status == "OK"){
                print(self.reverseGeoCodeResults?.results?[0].formattedAddress ?? "")
            }
            */
            
            
        }
        task.resume()
    }
    
    // MARK: - Places API
    internal func getPlace(placeId: String) {
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id="
                            + placeId + "&fields=name%2Crating%2Cformatted_phone_number&key=" + config.getApiKey())
        else{
            print("ERROR: Malformed Request (GET PLACE)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let placeStruct = try decoder.decode(PlaceResponseStruct.self, from: data)
                    self.placeResults = placeStruct
                } catch {
                    print("ERROR: Could not decode JSON response (GET PLACE)")
                }
            }
            
            print("PLACE API CALL: " + placeId)
            /*
             // print JSON for testing purposes
             if let data = data, let string = String(data: data, encoding: .utf8){
             print(string)
             }
             */
            
        }
        task.resume()
    }
    
    
    private func addLocationFromAPI(givenTime:Date, givenLat: Double, givenLong: Double, givenAlt: Double, givenName:String){
        
        let nameDB = Name(context: viewContext)
        let location = Location(context: viewContext)
        location.time=givenTime
        location.latitude = Double(givenLat)
        location.longitude = Double(givenLong)
        location.altitude = Double(givenAlt)
        let count = getCount(Name: givenName)
        location.name = givenName
        
        
        // find if exists first
        // if no, initialize count to 1
        // if yes, fetch request, modify count to +1
        if (count==1){
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
            fetchRequest.predicate = NSPredicate(format: "(name = %@)", givenName)
            let result = try! viewContext.fetch(fetchRequest)
            let objectUpdate = result[0] as! NSManagedObject
            let curCount = objectUpdate.value(forKey: "count")
            objectUpdate.setValue(curCount as! Int+1, forKey: "count")
        }
        else{
            nameDB.name=givenName
            nameDB.count = 1
        }

        saveContext()
    }

    private func getCount(Name: String) -> Int {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
       fetchRequest.predicate = NSPredicate(format: "(name = %@)", Name)
        let count = try! viewContext.count(for:fetchRequest)
       return count
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("An error occured: \(error)")
        }
    }




}
