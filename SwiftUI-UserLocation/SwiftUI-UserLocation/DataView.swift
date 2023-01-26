
//  DataView.swift
//  DataDemo
//
//  Created by CS Lab User on 1/25/23.


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
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Location.entity(), sortDescriptors: [])
    private var locations: FetchedResults<Location>
    
    @FetchRequest(entity: Timestamp.entity(), sortDescriptors: [])
    private var timestamps: FetchedResults<Timestamp>

    var body: some View {
            NavigationView {
                VStack {
                    TextField("Timestamp", text: $time)
                    TextField("Latitude", text: $latitude)
                    TextField("Longitude", text: $longitude)
                    TextField("Altitude", text: $altitude)
                    TextField("Name", text: $name)
                    
                    
                    HStack {
                        Spacer()
                        Button("Add") {
                            addLocation()
                        }
                        Spacer()
                        Button("Clear") {
                            time = ""
                            latitude = ""
                            longitude = ""
                            altitude = ""
                            name = ""
                            
                       }
                       Spacer()
                        Button("Export CSV") {
                            exportCSV()
                            time = ""
                            latitude = ""
                            longitude = ""
                            altitude = ""
                            name = ""
                   }
                        Spacer()
                        Button(action: {openFile.toggle()}, label: {
                            Text("Import CSV")
                            
                             
                    })
                    }
                   .padding()
                   .frame(maxWidth: .infinity)
                   
                    List {
                        ForEach(timestamps) { timestamp in
                            HStack {
                                Text(castToString(givenDate:timestamp.time!) )
                                Spacer()
                                Text(timestamp.place!.name ?? "no")
                                Spacer()
                                Text( String(format: "%f", timestamp.place!.altitude) )
                                Spacer()
                                Text(String(format: "%f", timestamp.place!.altitude) )
                                Spacer()
                                Text(String(format: "%f", timestamp.place!.altitude) )
                                Spacer()

                            }
                        }
                        .onDelete(perform: deleteLocations)
                        
                    }
                   .navigationTitle("Location Database")
               }
                .fileImporter(isPresented: $openFile, allowedContentTypes: [.commaSeparatedText], allowsMultipleSelection: false){ (res) in
                    do{
                        let fileURL=try res.get()[0]
//                        debugPrint(fileURL)
                        importCSV(url: fileURL)
                    }
                    catch{
                        debugPrint("error")
                        debugPrint(error.localizedDescription)
                    }
                }
               .padding()
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
                let timestamp = Timestamp(context: viewContext)
                let location = Location(context: viewContext)
                let addDateFormatter = DateFormatter()
                addDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                timestamp.time = addDateFormatter.date(from: time) ?? Date()
//                debugPrint(time)
//                debugPrint(addDateFormatter.date(from: time))
                location.addToTimes(timestamp)
                location.latitude = Double(latitude) ?? 0.0
                location.longitude = Double(longitude) ?? 0.0
                location.altitude = Double(altitude) ?? 0.0
                location.name = name
                // find if exists first
                // if no, initialize count to 1
                // if yes, fetch request, modify count to +1
                location.count = 1
                saveContext()
            }
        }
        
        private func saveContext() {
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError
                fatalError("An error occured: \(error)")
            }
        }
    
    private func deleteLocations(offsets: IndexSet) {
        // not sure if actually deletes properly or nah, but looks like it
        withAnimation {
            offsets.map { timestamps[$0] }.forEach(viewContext.delete)
                saveContext()
            }
    }
    
    func exportCSV() {
            let fileName = "export.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            var csvText = "Timestamp,Longitude,Latitude,Altitude,Name\n"

            for timestamp in timestamps {
                csvText += "\(timestamp.time! ), \(timestamp.place!.longitude  ),\(timestamp.place!.latitude ),\(timestamp.place!.altitude ),\(timestamp.place!.name ?? "Not Found")\n"
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
                        let columns = row.components(separatedBy: ",")
                        let timestamp = Timestamp(context: viewContext)
                        let location = Location(context: viewContext)
                        let castedDate = importDateFormatter.date(from: columns[0] )
//                        debugPrint(columns[0])
//                        debugPrint(castedDate)
                        timestamp.time = castedDate ?? Date()
                        location.longitude = Double(columns[1]) ?? 0.0
                        location.latitude = Double(columns[2]) ?? 0.0
                        location.altitude = Double(columns[3]) ?? 0.0
                        location.name = columns[4]
                        location.addToTimes(timestamp)
                        location.count = 1
                        saveContext()
                        
                    }
                    

                }
                    
            
            
            }
            catch {
                debugPrint("please help")
            }
        
        
        
        }
    
    



    struct DataView_Previews: PreviewProvider {
        static var previews: some View {
            DataView()
        }
    }
    

}
