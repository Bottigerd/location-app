//
//  SwiftUI_UserLocationApp.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//
import MapKit
import SwiftUI

@main
struct SwiftUI_UserLocationApp: App {
  let persistenceController = PersistenceController.shared
  var body: some Scene {
    WindowGroup {
      TabView {
        ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
          .tabItem {
            Label("Map", systemImage: "map.fill")
          }
        DataView().environment(\.managedObjectContext, persistenceController.container.viewContext)
          .tabItem {
            Label("Data", systemImage: "chart.bar")
          }
        InferenceView().environment(\.managedObjectContext, persistenceController.container.viewContext)
          .tabItem {
            Label("Inference", systemImage: "list.number")
          }
      }
    }
  }
}

