//
//  Location+CoreDataProperties.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/25/23.
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
    @NSManaged public var count: Int16
    @NSManaged public var times: NSSet?

}

// MARK: Generated accessors for times
extension Location {

    @objc(addTimesObject:)
    @NSManaged public func addToTimes(_ value: Timestamp)

    @objc(removeTimesObject:)
    @NSManaged public func removeFromTimes(_ value: Timestamp)

    @objc(addTimes:)
    @NSManaged public func addToTimes(_ values: NSSet)

    @objc(removeTimes:)
    @NSManaged public func removeFromTimes(_ values: NSSet)

}

extension Location : Identifiable {

}
