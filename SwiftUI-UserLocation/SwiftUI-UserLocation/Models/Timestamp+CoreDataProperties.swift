//
//  Timestamp+CoreDataProperties.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/25/23.
//
//

import Foundation
import CoreData


extension Timestamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timestamp> {
        return NSFetchRequest<Timestamp>(entityName: "Timestamp")
    }

    @NSManaged public var time: Date?
    @NSManaged public var place: Location?

}

extension Timestamp : Identifiable {

}
