//
//  ContentViewModel.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//

import CoreData
import MapKit
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.331516,                                                                              longitude: -121.891054)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

struct ResponseStruct: Codable {
    let plusCode: PlusCodeStruct
    let results: [Result]
    let status: String

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

struct Result: Codable {
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

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    
    //whenever this region changes our UI will update
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    
    
    @Published var coordinates: Array<String> = ["0","0"]
    
    @Published var address: String = "Pending Address"
    
    var placeID: String = "temp"
    var locationManager: CLLocationManager?
    var viewContext = PersistenceController.shared.container.viewContext
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            checkLocationAuthorization()
            
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        addLocationFromAPI(givenTime: Date() , givenLat: Double(coordinates[0]) ?? 0.0 , givenLong: Double(coordinates[1]) ?? 0.0, givenAlt: 0, givenName: placeID)
        

        
        @unknown default:
            break
        }
    
    }
    
    private func addLocationFromAPI(givenTime:Date, givenLat: Double, givenLong: Double, givenAlt: Double, givenName:String){
        
        let name_db = Name(context: viewContext)
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
            name_db.name=givenName
            name_db.count = 1
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

    
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> Array<String> {
        return [coordinates2d.latitude.description, coordinates2d.longitude.description]
    }
    
    func getLocationName() {
    
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + coordinates[0] + "," + coordinates[1] + "&location_type=ROOFTOP&result_type=street_address&key=\(Configuration.apiKey)")
        else{
            print("ERROR: Malformed Request")
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let tasks = try decoder.decode(ResponseStruct.self, from: data)
                    //self.address = tasks.results[0].formattedAddress //causing thread error, commenting out for now
                    
                    self.placeID = " tasks.results[0].placeID"
                    
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





