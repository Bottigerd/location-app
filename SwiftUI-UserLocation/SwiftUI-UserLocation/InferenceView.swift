//
//  InferenceView.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/29/23.
//

import SwiftUI
import CoreData

struct InferenceView: View {
    var places = [String]()
    var times = [Date]()
    let viewContext = PersistenceController.shared.container.viewContext

    
    
    var body: some View {
        VStack{
            Text("Information we know based on your location data: ")
            Text(gethome())
            Button("test") {
                test()}
//
//
//            Text(getTop 5Locations())
        }
    }
    
    //Returns user's home based on data from last four days
    private func gethome() -> String{
        //dictory to store all locations between 10pm-8am and the hours spent there
        var home = Dictionary<String, Double>()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let start = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        
        let data = getAllLocationWithinRange(startTime: start, endTime: date)
        
        //if no data
        if (data.count == 0){
            return "Insufficient Data. Not enough to make an inference!"
        }
        
        //loop through data
        //NOTE: cases to handle: what if they get home before 10pm?
        //also what if no data from next morning? - have a default end time
        var i = 0
        var originloc = data[0]
        while(i != data.count-1){
            i += 1
            if (originloc.name != data[i].name){
                let time_s = dateFormatter.string(from: originloc.time!)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]

                if ((Int(hours.prefix(2)) ?? 0 >= 22) || (Int(hours.prefix(2)) ?? 0 <= 8) ) {
                    let interval = data[i].time?.timeIntervalSince(originloc.time!)
                    //check if key exists in map, add interval to curr value
                    if (home[originloc.name!] != nil)
                    {
                        home[originloc.name ?? "Invalid location"] = home[originloc.name ?? "Invalid location"]! + (interval ?? 0.0)
                    }else {
                        home[originloc.name ?? "Invalid Location"] = interval
                    }
                    originloc = data[i]
                } else {
                    originloc = data[i]
                }
            }
        }
        
        //No data from 10pm-8am
        if (home.isEmpty == true){
            return "Not enough data recieved between 10:00pm and 08:00am"
        }
        let maxVal = home.values.max() ?? 0
        let keys = home.filter { (k, v) -> Bool in v == maxVal}.map{ (k, v) -> String in k}
        let address = "You most likely live in " +  keys[0]
        return address

    }
    
    //Cassat 5
    //Olin 1
    //Watson 3
    //Anserson 4
    //Sayles 7
    //Leighton 9
    //Libe 12
    //[C,L,Li,A,S]
    //[5,9,12,4,7]
    
    //returns the 5 most frequented locations of user excluding their home
    private func getTop5Locations() -> String{
        //IMPORTANT it doesn't delete API calls from data yet
        let data = getAllLocationCounts();
        print(data.count)
        if((data.count < 5) || (data[4].name == nil)){
            return "Less than 5 locations in data"
        }
        else{
            var topPlaces: Array<String> = Array();
            topPlaces = [data[0].name!, data[1].name!, data[2].name!, data[3].name!, data[4].name!]
            var topCounts: Array<Int16> = Array();
            topCounts = [data[0].count, data[1].count, data[2].count, data[3].count, data[4].count]
            var min = topCounts.min();
            
            for i in data{
                if((i.name != nil) && (!topPlaces.contains(i.name!)) && (min! < i.count)) {
                        //print(i.name!)
                    var index = topCounts.firstIndex(of: min!)
                    topCounts[index!] = i.count
                    topPlaces[index!] = i.name!
                    min = topCounts.min()
                }
            }
            
            let ret =  topPlaces.joined(separator: ",")
            return ret

        }
        return "hi"
    }
    
    
    // gets all location data from CoreData. Location data includes name,latitude,longitude,altitude and timestamp
    private func getAllLocationHistory() -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
        for i in result{
            print(i.name ?? "hi")
        }
        return result
    }
    
    
    
    // gets all counts for all locations. access results the same way as getAllLocationHistory()
    private func getAllLocationCounts() -> [Name] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
        
        let sortOrder = NSSortDescriptor(key: "count", ascending: false)
        fetchRequest.sortDescriptors = [sortOrder]
        let result = try! viewContext.fetch(fetchRequest) as! [Name]
        debugPrint(result)
        return result
        
    }
    
//   to see how the startTime and endTime formats should be, see Test() function below. Sorts in reverse chronological order with latest being first. if you want to invert it, just make 'ascending: true'
    
    private func getAllLocationWithinRange(startTime: Date, endTime: Date) -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let sortOrder = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.predicate = NSPredicate(format: "(time >= %@) AND (time <= %@)", startTime as CVarArg, endTime as CVarArg)
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
//        debugPrint(result)
        return result
        
    }
    
    private func test(){
//        let date_1_str = "2022-03-20 10:15:30"
//        let date_2_str = "2022-08-20 10:15:30"
//        let addDateFormatter = DateFormatter()
//        addDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date_1=addDateFormatter.date(from: date_1_str) ?? Date()
//        let date_2=addDateFormatter.date(from: date_2_str) ?? Date()
//        getAllLocationWithinRange(startTime: date_1, endTime: date_2)
        getAllLocationCounts()
    }
//

    
    
    
    

}

struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
