//
//  Name+CoreDataProperties.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/28/23.
//
//

import Foundation
import CoreData


extension Name {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Name> {
        return NSFetchRequest<Name>(entityName: "Name")
    }

    @NSManaged public var count: Int16
    @NSManaged public var name: String?

}

extension Name : Identifiable {

}
