//
//  MapView.swift
//  SwiftUI-UserLocation
//
//  Created by Amir Al-Sheikh on 2/13/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreData
import UniformTypeIdentifiers


struct MapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Location.entity(), sortDescriptors: [])
    private var locations: FetchedResults<Location>
    @State private var polylineCoordinates: [CLLocationCoordinate2D]?
    @State private var centerCoordinate = CLLocationCoordinate2D()
    


  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.region = region
    
  //  if let polylines = polylineCoordinates {
    //  let polyline = MKPolyline(coordinates: polylines, count: polylines.count)
//      mapView.addOverlay(polyline)
  //  }
     
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

}

class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapView

  init(_ parent: MapView) {
   self.parent = parent
  }
   
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let routePolyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(polyline: routePolyline)
      renderer.strokeColor = UIColor.systemBlue
      renderer.lineWidth = 5
      return renderer
    }
    return MKOverlayRenderer()
  }
}
