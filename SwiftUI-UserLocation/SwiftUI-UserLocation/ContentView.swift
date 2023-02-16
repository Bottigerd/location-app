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
    @StateObject private var viewModel = ContentViewModel()
    

    var body: some View {
        VStack{
            Text(viewModel.address);
            Button(action: {
                viewModel.startUpdatingLocation()
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
                    let locServicesEnabled = viewModel.setupLocationManager()
                    let locServicesValidType = viewModel.checkLocationAuthorizationType()
                    if (locServicesEnabled && locServicesValidType){
                        viewModel.startUpdatingLocation()
                    }
                }

        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




