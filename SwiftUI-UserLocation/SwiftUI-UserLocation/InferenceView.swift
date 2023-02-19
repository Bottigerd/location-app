//
//  InferenceView.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/29/23.
//

import SwiftUI
import CoreData
import Foundation

//Credit to Stack Overflow: Vasily Bodnarchuk
extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

struct InferenceView: View {
    var places = [String]()
    var times = [Date]()
    let viewContext = PersistenceController.shared.container.viewContext

    
    var body: some View {
        VStack{
            Text("Information we know based on your location data: ")
            Text(gethome())
            Text(getTop5Locations())
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
        var i = 0
        var originloc = data[0]
        while(i != data.count-1){
            i += 1
            if (originloc.name != data[i].name){
                let time_s = dateFormatter.string(from: originloc.time!)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]
                
                
                if ((Int(hours.prefix(2)) ?? 0 >= 22) || (Int(hours.prefix(2)) ?? 0 <= 8) || ((Int(hours.prefix(2)) ?? 0 < 22) && (data[i].time!.distance(from: originloc.time!, only: .day) == 1)) ) {
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
    
    
    //returns the 5 most frequented locations of user
    private func getTop5Locations() -> String{
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
                    let index = topCounts.firstIndex(of: min!)
                    topCounts[index!] = i.count
                    topPlaces[index!] = i.name!
                    min = topCounts.min()
                }
            }
            
            let top5 = [
                topPlaces[0] : topCounts[0],
                topPlaces[1] : topCounts[1],
                topPlaces[2] : topCounts[2],
                topPlaces[3] : topCounts[3],
                topPlaces[4] : topCounts[4]
            ]

            let sortedVals = top5.sorted { $0.1 > $1.1 }
            
            var ret =  "Here Are Your Top 5 Places On Campus: \n"
            var topcount = 1
            for (place, count) in sortedVals{
                print(topcount, place)
                ret += String(topcount) + " " + place + "\n"
                topcount += 1
            }
            return ret

        }
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
    
   // private func test(){
//        let date_1_str = "2022-03-20 10:15:30"
//        let date_2_str = "2022-08-20 10:15:30"
//        let addDateFormatter = DateFormatter()
//        addDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date_1=addDateFormatter.date(from: date_1_str) ?? Date()
//        let date_2=addDateFormatter.date(from: date_2_str) ?? Date()
//        getAllLocationWithinRange(startTime: date_1, endTime: date_2)
        //getAllLocationCounts()
   // }
//

    
    
    
    

}

struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
