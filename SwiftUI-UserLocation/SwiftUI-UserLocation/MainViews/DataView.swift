
//  DataView.swift
//
//  Created by CS Lab User on 1/25/23.

// Initial Version built following a tutorial from here https://www.answertopia.com/ios/an-ios-core-data-tutorial/

// Data View:
// This view allows you to view all location logs, import data from a CSV file, and export data to a CSV file.


import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct DataView: View {
    
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var altitude: String = ""
    @State var name: String = ""
    @State var time: String = ""
    @State var count: String = ""
    @State private var isShareSheetShowing = false
    @State private var showDocumentPicker = false
    @State private var fileContent = ""
    @State var fileName=""
    @State var fileURL=URL(string: "https://www.google.com")
    @State var openFile=false
    @State var dateFormatter = DateFormatter()
    @State private var showingAlert = false

    
    let viewContext = PersistenceController.shared.container.viewContext
    @FetchRequest(entity: Location.entity(), sortDescriptors: [])
    private var locations: FetchedResults<Location>
    
    @FetchRequest(entity: Name.entity(), sortDescriptors: [])
    private var names: FetchedResults<Name>

    var body: some View {
            NavigationView {
                VStack(spacing: -15) {
                    HStack {
                        Button(action: {openFile.toggle()}, label: {
                            Text("Import \nCSV")
                    })
                        Spacer()
                        Button("Nuke") {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Are you sure you want to clear all data?"),
                                message: Text("There is no undo"),
                                primaryButton: .destructive(Text("Delete")) {
                                    nukeData()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        Spacer()
                        Button("Export \nCSV") {
                            exportCSV()
                            time = ""
                            latitude = ""
                            longitude = ""
                            altitude = ""
                            name = ""
                   }
                    }
                    .padding()
                   .frame(maxWidth: .infinity)
                    List {
                        ForEach(locations) { location in
                            HStack {
                               
                                Text(castToString(givenDate:location.time!)).font(Font.system(size:13))
                                Spacer()
                                Text(location.name ?? "no").font(Font.system(size:13))
                                Spacer()
                                Text( String(format: "%f", location.latitude)).font(Font.system(size:13))
                                Spacer()
                                Text(String(format: "%f", location.longitude)).font(Font.system(size:13))
                                Spacer()
                                Text(String(format: "%f", location.altitude)).font(Font.system(size:13))
                            }
                        }
                        .onDelete(perform: deleteLocations)
                    }
                   .navigationTitle("Location History")
               }
//                Credit to Stack Overflow: Sergei Volkov
                .fileImporter(isPresented: $openFile, allowedContentTypes: [.commaSeparatedText], allowsMultipleSelection: false){ (res) in
                    do{
                        let fileURL=try res.get()[0]
                        importCSV(url: fileURL)
                    }
                    catch{
                        debugPrint("error")
                        debugPrint(error.localizedDescription)
                    }
                }
               .textFieldStyle(RoundedBorderTextFieldStyle())
           }
       }
    

    private func castToString(givenDate: Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let castedDate = dateFormatter.string(from: givenDate )
        return castedDate
    }
    
    private func addLocation() {
            
            withAnimation {
                
                let location = Location(context: viewContext)
                let addDateFormatter = DateFormatter()
                addDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                location.time = addDateFormatter.date(from: time) ?? Date()
                location.latitude = Double(latitude) ?? 0.0
                location.longitude = Double(longitude) ?? 0.0
                location.altitude = Double(altitude) ?? 0.0
                let count = getCount(Name: name)
                location.name = name
                // find if exists first
                // if no, initialize count to 1
                // if yes, fetch request, modify count to +1
                
                if (count==1){
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
                    fetchRequest.predicate = NSPredicate(format: "(name = %@)", name)
                    let result = try! viewContext.fetch(fetchRequest)
                    let objectUpdate = result[0] as! NSManagedObject
                    let curCount = objectUpdate.value(forKey: "count")
                    objectUpdate.setValue(curCount as! Int+1, forKey: "count")
                }
                else{
                    let name_db = Name(context: viewContext)
                    name_db.name=name
                    name_db.count = 1
                }
        
                saveContext()
            }
        }
    
    func getCount(Name: String) -> Int {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
       fetchRequest.predicate = NSPredicate(format: "(name = %@)", Name)
        let count = try! viewContext.count(for:fetchRequest)
       return count
    }
        
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("An error occured: \(error)")
        }
    }
    
    private func deleteLocations(offsets: IndexSet) {
        let deleted_name = offsets.map{locations[$0]}[0].value(forKey: "name") as! NSString
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
        fetchRequest.predicate = NSPredicate(format: "(name = %@)", deleted_name)
        let result = try! viewContext.fetch(fetchRequest)
        let objectUpdate = result[0] as! NSManagedObject
        let curCount = objectUpdate.value(forKey: "count") as! Int
        
        if curCount>1{
            objectUpdate.setValue(curCount-1, forKey: "count")
        } else{
            viewContext.delete(objectUpdate)
        }
        
        saveContext()
        
        withAnimation {
            offsets.map { locations[$0] }.forEach(viewContext.delete)
                saveContext()
            
            }
        
    }
    
    
    // Deletes all data from core data (from both Entities)
    private func nukeData() {
//        On the offchance that there is a performance issue, uncomment
//        the following two lines and delete the "for name in names" loop
        
        for location in locations {
            viewContext.delete(location)
        }
        for name in names {
            viewContext.delete(name)
        }
        
        saveContext()

    }

    // Deletes an entire fetch request from core data
    private func batchDeletion(fetch: NSFetchRequest<NSFetchRequestResult>){
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        do {
            _ = try viewContext.execute(batchDeleteRequest) as! NSBatchDeleteResult
        } catch {
            fatalError("Failed to execute request: \(error)")
        }

        do {
            let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [viewContext])
        } catch {
            fatalError("Failed to perform batch update: \(error)")
        }
        
        saveContext()
    }
    
    
    // Debugging: Prints out how many objects are in Location entity
    func getLocationRecordsCount(){
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
           do {
               let count = try viewContext.count(for: fetchRequest)
               print(count)
           } catch {
               print(error.localizedDescription)
           }

       }
    
    // Debugging: Prints out how many objects are in Name entity
    func getNameRecordsCount(){
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
           do {
               let count = try viewContext.count(for: fetchRequest)
               print(count)
           } catch {
               print(error.localizedDescription)
           }
       }

    
    //   Credit to Stack Overflow: Justin Chung
    func exportCSV() {
            let fileName = "export.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            var csvText = "Timestamp;Latitude;Longitude;Altitude;Name\n"

            for location in locations {
                csvText += "\(location.time! );\(location.latitude  );\(location.longitude );\(location.altitude );\(location.name ?? "Not Found")\n"
            }

            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            print(path ?? "not found")

            var filesToShare = [Any]()
            filesToShare.append(path!)
            let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            isShareSheetShowing.toggle()
        }
    
    func importCSV(url:URL){
        do {
                let data = try String(contentsOf: url, encoding: .utf8)
                var rows = data.components(separatedBy: "\n")
                let importDateFormatter = DateFormatter()
                importDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                rows.removeFirst()
                for row in rows {
                    if !row.isEmpty{
                        let columns = row.components(separatedBy: ";")
                        let location = Location(context: viewContext)
                        
                        let castedDate = importDateFormatter.date(from: columns[0] )
                        location.time = castedDate ?? Date()
                        location.latitude = Double(columns[1]) ?? 0.0
                        location.longitude = Double(columns[2]) ?? 0.0
                        location.altitude = Double(columns[3]) ?? 0.0
                        location.name = columns[4]
                        let count = getCount(Name: columns[4])
                        
                        if (count==1){
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
                            fetchRequest.predicate = NSPredicate(format: "(name = %@)", columns[4])
                            let result = try! viewContext.fetch(fetchRequest)
                            let objectUpdate = result[0] as! NSManagedObject
                            let curCount = objectUpdate.value(forKey: "count")
                            objectUpdate.setValue(curCount as! Int+1, forKey: "count")
                        }
                        else{
                            let name_db = Name(context: viewContext)
                            name_db.name=columns[4]
                            name_db.count = 1
                        }
                        saveContext()
                        
                        
                    }
                    

                }
                    
            
            
            }
            catch {
                debugPrint("please help")
            }
        
        
        
        }
    
    // gets all location data from CoreData. Location data includes name,latitude,longitude,altitude and timestamp
     func getAllLocationHistory() -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let result = try! viewContext.fetch(fetchRequest) as! [Location]

        return result
    }
    
    
    
    // gets all counts for all locations. access results the same way as getAllLocationHistory()
     func getAllLocationCounts() -> [Name] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
        let sortOrder = NSSortDescriptor(key: "count", ascending: false)
        fetchRequest.sortDescriptors = [sortOrder]
        let result = try! viewContext.fetch(fetchRequest) as! [Name]
         
        return result
        
    }
    
//   to see how the startTime and endTime formats should be, see Test() function below. Sorts in reverse chronological order with latest being first. if you want to invert it, just make 'ascending: true'
     func getAllLocationWithinRange(startTime: Date, endTime: Date) -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let sortOrder = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.predicate = NSPredicate(format: "(time >= %@) AND (time <= %@)", startTime as CVarArg, endTime as CVarArg)
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
        return result
        
    }
    
    



    struct DataView_Previews: PreviewProvider {
        static var previews: some View {
            DataView()
        }
    }
    

}
