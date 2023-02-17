//
//  NavigationTabs.swift
//  SwiftUI-UserLocation
//
//  Created by Kitty Tyree on 2/12/23.
//
//  Navigation Tabs View:
//  Tab Bar View Controller

import SwiftUI

struct NavigationTabs: View {
    let persistenceController = PersistenceController.shared
    var body: some View {            
        TabView{
            Group{
                ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem{
                        Label("Map", systemImage: "map.fill")
                    }
                DataView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem{
                        Label("Data", systemImage: "chart.bar")
                    }
                InferenceView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem{
                        Label("Inference", systemImage: "list.number")
                    }
            }
        }
    }
}


struct NavigationTabs_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTabs()
    }
}
