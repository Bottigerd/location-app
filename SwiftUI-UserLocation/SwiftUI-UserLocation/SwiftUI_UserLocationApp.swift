//
//  SwiftUI_UserLocationApp.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//
import MapKit
import SwiftUI
import GoogleMaps

@main
struct SwiftUI_UserLocationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  let persistenceController = PersistenceController.shared
  var body: some Scene {
    WindowGroup {
        LaunchScreen()
      }
    }
  }

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey(Config(fileName: "config").get_api_key())
        return true
    }
}
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
