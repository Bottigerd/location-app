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
    @State private var showData = false
    var body: some Scene {
        WindowGroup {
            if (showData){
                DataView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                Button(action: { showData = false
                                }, label: {
                                    Text("Map")
                                        .frame(width: 200, height: 40)
                                        .background(Color.green)
                                        .cornerRadius(15)
                                        .padding()
                                })
            }
            
            else{
            ContentView()
            Button(action: { showData = true
                            }, label: {
                                Text("Data")
                                    .frame(width: 200, height: 40)
                                    .background(Color.green)
                                    .cornerRadius(15)
                                    .padding()
                            })
            }
        }
    }
}

