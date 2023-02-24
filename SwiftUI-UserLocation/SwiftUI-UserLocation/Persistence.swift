//
//  Persistence.swift
//  CoreDataDemo
//
//  Created by CS Lab User on 1/25/23.
//

import CoreData
//
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Locations")

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Container load failed: \(error)")

            }
        }
    }
}

//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container = NSPersistentContainer(name: "Locations")
//
//        init () {
//            do {
//                if #available(iOS 15.0, *) {
//                    try container.persistentStoreCoordinator.destroyPersistentStore(at: container.persistentStoreDescriptions.first!.url!, type: .sqlite, options: nil)
//                } else {
//                    // Fallback on earlier versions
//                }
//                print("Success")
//            } catch {
//
//                print(error.localizedDescription)
//                print("Fail")
//            }
//
//        }}


