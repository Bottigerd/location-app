//
//  ContentView.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    //takes you to region
    let persistenceController = PersistenceController.shared
    @StateObject private var viewModel = ContentViewModel()
    let Data=DataView()
    
    

    var body: some View {
        
        Text(viewModel.address);
        Button(action: { viewModel.checkIfLocationServicesIsEnabled()
        }){
            Text("Get Location")
                .foregroundColor(Color.white)
                .padding()
            
            }

                
            .buttonStyle(.bordered)
            .background(Color.green)
            .cornerRadius(10)
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .ignoresSafeArea()
            .accentColor(Color(.systemPink))
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




