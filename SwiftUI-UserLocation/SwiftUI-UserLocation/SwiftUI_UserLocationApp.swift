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
        GMSServices.provideAPIKey("")
        return true
    }
}

