//
//  ViewController.swift
//  MyLocation
//
//  Created by CS Lab Account on 1/16/23.
//

import CoreLocationUI
import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 20, y: 50, width: view.frame.self.width-40, height: view.frame.size.height-220)
        manager.delegate = self
        createButton()
        // Do any additional setup after loading the view.
    }
    
    private func createButton() {
        let button = CLLocationButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.label = .currentLocation
        button.icon = .arrowOutline
        button.cornerRadius = 12
        button.center = CGPoint(x: view.center.x, y: view.frame.self.height-70)
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    //updates locations
    @objc func didTapButton(){
        manager.startUpdatingLocation()
    }
    
    //stops location after one use
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locations = locations.first else { return }
        self.manager.stopUpdatingLocation()
       
        mapView.setRegion(MKCoordinateRegion(center: locations.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
}

