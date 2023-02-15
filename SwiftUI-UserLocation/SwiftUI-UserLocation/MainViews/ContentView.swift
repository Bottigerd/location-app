//
//  ContentView.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/20/23.
//
// Content View:
// This view allows you to get the name of your location
// and see it on a map at the click of a button.

import SwiftUI
import MapKit

struct ContentView: View {
    //takes you to region
    @StateObject private var viewModel = ContentViewModel()
    

    var body: some View {
        VStack{
            Text(viewModel.address);
            Button(action: { viewModel.updateDisplay()}){
                Text("Get Location")
                    .foregroundColor(Color.white)
                    .padding()
                }
                .buttonStyle(.bordered)
                .background(Color.green)
                .cornerRadius(10)
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .accentColor(Color(.systemPink))
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
                    viewModel.updateLocation()
                }

        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




