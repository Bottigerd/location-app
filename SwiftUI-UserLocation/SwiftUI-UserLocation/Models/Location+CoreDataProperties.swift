//
//  Location+CoreDataProperties.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/28/23.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var time: Date?

}

extension Location : Identifiable {

}
