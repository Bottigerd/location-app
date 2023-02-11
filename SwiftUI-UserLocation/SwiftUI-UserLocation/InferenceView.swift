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
            

        }
        
        
    }
    
    
    //here's some sample code on how to access the data from getAllLocationHistory()
    //let data = getAllLocationHistory()
    //for location in data {
    //            var singleRow=[location.name!,location.latitude,location.altitude,location.longitude,location.time!] as [Any]
    //            do xyz....
    //        }

    private func gethome() -> String{
        var home = Dictionary<String, Int>()
        //storeData()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print(dateFormatter.string(from: date))
        //end is today current time
        //start is 4 days before today (10 pm)
        let start = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        print(dateFormatter.string(from: start))
        
        let data = getAllLocationWithinRange(startTime: start, endTime: date)
        for i in data{
            let time = i.time
            if let time = time {
                let time_s = dateFormatter.string(from: time)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]
                
                if ((Int(hours.prefix(2)) ?? 0 >= 22) || (Int(hours.prefix(2)) ?? 0 <= 8) ) {
                    
                }
                
            }
            
            
        }
        
        //filter the data to only include 10pm-7am
        
        //loop through
        //calculate time for each name change, add it to map (Name = key, TimeSpent = value)
//        for i in 0...times.count{
//
//            //var hoursSpent = times[i+1].timeIntervalSince(times[i])
//            //print(hoursSpent)
//        }
        
        //go through map to find highest value -> that key is home
        
        let address = "HOME: Cassat"
        return address

    }
    
//    private func storeData() {
//        let data = getAllLocationHistory()
//        for i in data{
//            //print(i.name ?? "hi")
//            let j = String(i.name ?? "hi")
//            places.append(j)
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy/MM/dd HH:mm"
//            let someDateTime = formatter.date(from: "2016/10/08 22:31")
//            times.append((i.time ?? someDateTime)!)
//        }
//    }
    
    
    
    // gets all location data from CoreData. Location data includes name,latitude,longitude,altitude and timestamp
    private func getAllLocationHistory() -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
        for i in result{
            print(i.name ?? "hi")
        }
        return result
    }
    
    private func getAllLocationCounts() -> [NSFetchRequestResult] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Name")
        
        let sortOrder = NSSortDescriptor(key: "count", ascending: false)
        fetchRequest.sortDescriptors = [sortOrder]
        let result = try! viewContext.fetch(fetchRequest)
//        debugPrint(result)
        return result
        
    }
    
//   to see how the startTime and endTime formats should be, see Test() function below. Sorts in reverse chronological order with latest being first. if you want to invert it, just make 'ascending: true'
    
    private func getAllLocationWithinRange(startTime: Date, endTime: Date) -> [Location] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let sortOrder = NSSortDescriptor(key: "time", ascending: false)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.predicate = NSPredicate(format: "(time >= %@) AND (time <= %@)", startTime as CVarArg, endTime as CVarArg)
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
//        debugPrint(result)
        return result
        
    }
    
//    private func test(){
//        let date_1_str = "2022-03-20 10:15:30"
//        let date_2_str = "2022-08-20 10:15:30"
//        let addDateFormatter = DateFormatter()
//        addDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date_1=addDateFormatter.date(from: date_1_str) ?? Date()
//        let date_2=addDateFormatter.date(from: date_2_str) ?? Date()
//        getAllLocationWithinRange(startTime: date_1, endTime: date_2)
//        getAllLocationCounts()
//    }
//

    
    
    
    

}

struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
