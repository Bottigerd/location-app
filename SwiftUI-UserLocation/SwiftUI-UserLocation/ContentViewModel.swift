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

/*
 MARK: - ReverseGeoCodingResponseStruct
 */
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
    let result: PlaceResult?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case result, status
    }
}

struct PlaceResult: Codable {
    let addressComponents: [AddressComponentStruct]
    let adrAddress, businessStatus: String
    let currentOpeningHours: CurrentOpeningHoursStruct
    let formattedAddress, formattedPhoneNumber: String
    let geometry: GeometryStruct
    let icon: String
    let iconBackgroundColor: String
    let iconMaskBaseURI: String
    let internationalPhoneNumber, name: String
    let openingHours: OpeningHoursStruct
    let photos: [PhotoStruct]
    let placeID: String
    let plusCode: PlusCodeStruct
    let rating: Int
    let reference: String
    let reviews: [ReviewStruct]
    let types: [String]
    let url: String
    let userRatingsTotal, utcOffset: Int
    let vicinity: String
    let website: String
    let wheelchairAccessibleEntrance: Bool

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case adrAddress = "adr_address"
        case businessStatus = "business_status"
        case currentOpeningHours = "current_opening_hours"
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case geometry, icon
        case iconBackgroundColor = "icon_background_color"
        case iconMaskBaseURI = "icon_mask_base_uri"
        case internationalPhoneNumber = "international_phone_number"
        case name
        case openingHours = "opening_hours"
        case photos
        case placeID = "place_id"
        case plusCode = "plus_code"
        case rating, reference, reviews, types, url
        case userRatingsTotal = "user_ratings_total"
        case utcOffset = "utc_offset"
        case vicinity, website
        case wheelchairAccessibleEntrance = "wheelchair_accessible_entrance"
    }
}

struct CurrentOpeningHoursStruct: Codable {
    let openNow: Bool
    let periods: [CurrentOpeningHoursPeriodStruct]
    let weekdayText: [String]

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }
}

struct CurrentOpeningHoursPeriodStruct: Codable {
    let close, periodOpen: PurpleCloseStruct

    enum CodingKeys: String, CodingKey {
        case close
        case periodOpen = "open"
    }
}

struct PurpleCloseStruct: Codable {
    let date: String
    let day: Int
    let time: String
}

struct OpeningHoursStruct: Codable {
    let openNow: Bool
    let periods: [OpeningHoursPeriodStruct]
    let weekdayText: [String]

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }
}

struct OpeningHoursPeriodStruct: Codable {
    let close, periodOpen: FluffyCloseStruct

    enum CodingKeys: String, CodingKey {
        case close
        case periodOpen = "open"
    }
}

struct FluffyCloseStruct: Codable {
    let day: Int
    let time: String
}

struct PhotoStruct: Codable {
    let height: Int
    let htmlAttributions: [String]
    let photoReference: String
    let width: Int

    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
}

struct ReviewStruct: Codable {
    let authorName: String
    let authorURL: String
    let language, originalLanguage: String
    let profilePhotoURL: String
    let rating: Int
    let relativeTimeDescription, text: String
    let time: Int
    let translated: Bool

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case authorURL = "author_url"
        case language
        case originalLanguage = "original_language"
        case profilePhotoURL = "profile_photo_url"
        case rating
        case relativeTimeDescription = "relative_time_description"
        case text, time, translated
    }
}

/*
 MARK: - CONTENT VIEW MODEL
 */

final class ContentViewModel: NSObject, ObservableObject,
                              CLLocationManagerDelegate {
    
    // MARK: - Important Variables
    //whenever this region changes our UI will update
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               span: MapDetails.defaultSpan)
    
    // published so it can be referenced by ContentView
    @Published var address: String = "Pending Address"
    
    var previous_coordinates = MapDetails.startingLocation
    
    // API Responses (URLSession discards response before completion, so we save to a global variable
    var reverse_geo_code_results: ReverseGeoCodingResponseStruct?
    var place_results: PlaceResponseStruct?
    
    // DO NOT PUSH WITH THIS FILLED
    var API_KEY: String = ""
    
    var locationManager: CLLocationManager?
    
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
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location is restricted likely due to parental controls")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
            
            // if locationManager fails to get location, revert to previously fetched coordinates
            let coordinates = locationManager.location?.coordinate ?? previous_coordinates
            region = MKCoordinateRegion(center: coordinates,
                                        span: MapDetails.defaultSpan)
            
            let coordinates_string = getCoordinatesString(coordinates2d: coordinates)
            previous_coordinates =  coordinates
            // in case the next get location fails, save the current coordinates as the previous ones
            
            getReverseGeocode(coordinates: coordinates_string)
            let place_id = reverse_geo_code_results?.results?[0].placeID ?? nil
            
            if (place_id != nil) {
                getPlace(place_id: place_id!)
                // force upwrapping because we should only go into the if statement if its not nil
                address = place_results?.result?.name ?? reverse_geo_code_results?.results?[0].formattedAddress ?? "PendingLocation"
            }
            else {
                address = reverse_geo_code_results?.results?[0].formattedAddress ?? "Pending Location"
            }
            
        @unknown default:
            break
        }
        
    }
    
    // returns coordinates from a CLLocationCoordinate2D as a string for API usage
    internal func getCoordinatesString(coordinates2d: CLLocationCoordinate2D) -> String {
        return coordinates2d.latitude.description + "," + coordinates2d.longitude.description
    }
    
    // MARK: - Reverse Geocoding
    // transforms the json from the reverse geocoding API call into a struct for referencing
    internal func getReverseGeocode(coordinates: String) {
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
                    let reverse_geo_code_struct = try? decoder.decode(ReverseGeoCodingResponseStruct.self, from: data)
                    DispatchQueue.main.async {
                    self.reverse_geo_code_results = reverse_geo_code_struct
                    }
                } catch {
                    print("ERROR: Could not decode JSON response")
                    return
                }
            }
            
            print("REVERSE GEOCODING API CALL: " + coordinates)
            // print JSON for testing purposes
            if let data = data, let string = String(data: data, encoding: .utf8){
                print(string)
            }
            
        }.resume()
    }
    
    // MARK: - Place
    internal func getPlace(place_id: String) -> PlaceResponseStruct {
        var place_struct = PlaceResponseStruct(result: nil, status: nil)
        
        guard let url = URL(string: "  https://maps.googleapis.com/maps/api/place/details/json?place_id="
                             + place_id + "&fields=name%2Crating%2Cformatted_phone_number&key=" + API_KEY)
        else{
            print("ERROR: Malformed Request")
            return place_struct
        }
        
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    place_struct = try decoder.decode(PlaceResponseStruct.self, from: data)
                } catch {
                    print("ERROR: Could not decode JSON response")
                }
            }
            
            print("PLACE API CALL: " + place_id)
            // print JSON for testing purposes
            if let data = data, let string = String(data: data, encoding: .utf8){
                print(string)
            }
            
        }
        task.resume()
        return place_struct
    }
    
}





