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
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                DataView() //Replace with DataView when merged
                    .tabItem {
                        Label("Data", systemImage: "chart.bar")
                    }
                InferenceView()
                    .tabItem {
                        Label("Inference", systemImage: "list.number")
                    }
            }  
        }
    }
}

