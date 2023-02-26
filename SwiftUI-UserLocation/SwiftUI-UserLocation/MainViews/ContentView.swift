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
import UIKit
import GoogleMaps
import GoogleMapsUtils

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
            Text(viewModel.address)
            MapView(viewModel: viewModel)
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



struct MapView: UIViewControllerRepresentable{
    @StateObject var viewModel: ContentViewModel
    typealias UIViewControllerType = ViewController
    

    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController(viewModel: viewModel)
        // Do some configurations here if needed.
        return vc
        // Return MyViewController instance
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
        // Updates the state of the specified view controller with new information from SwiftUI.
        uiViewController.viewToReload()
        uiViewController.updateHeatMap()
    }
}

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    var viewModel : ContentViewModel!
    private var heatMapLayer : GMUHeatmapTileLayer!
    private var mapView : GMSMapView!
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    private var list = [GMUWeightedLatLng]()
    init (viewModel : ContentViewModel){
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        print(viewModel.fetchCoordinates())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let def_loc = viewModel.fetchCoordinates()
        print(def_loc)
        let camera = GMSCameraPosition.camera(withLatitude: def_loc.latitude, longitude: def_loc.longitude, zoom: 15)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        self.view = mapView
        self.viewWillAppear(true)
  
    }
    func viewToReload() {
        mapView.camera = GMSCameraPosition.camera(withTarget: viewModel.fetchCoordinates(), zoom: 15)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        heatMapLayer = GMUHeatmapTileLayer()
        heatMapLayer.radius = 80
        heatMapLayer.opacity = 1.0
        heatMapLayer.gradient = GMUGradient(colors: [UIColor.blue, UIColor.red], startPoints: gradientStartPoints, colorMapSize: 256)
        heatMapLayer.map = mapView
        
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
  }
    
    func updateHeatMap(){
        print("UPDATING UPDATING UPDATING UPDATING")
        let coordinate = GMUWeightedLatLng(coordinate: viewModel.fetchCoordinates() , intensity: 1.0)
        list.append(coordinate)
        heatMapLayer.weightedData = list
        heatMapLayer.map = mapView
        heatMapLayer.clearTileCache()
    
    }

}
