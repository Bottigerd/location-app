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

    private mutating func gethome() -> String{
        var home = Dictionary<String, Int>()
        storeData()
        for i in 0...times.count{
           
            var hoursSpent = times[i+1].timeIntervalSince(times[i])
            print(hoursSpent)
        }
        
        let address = "HOME: Cassat"
        return address

    }
    
    private mutating func storeData() {
        let data = getAllLocationHistory()
        for i in data{
            //print(i.name ?? "hi")
            let j = String(i.name ?? "hi")
            places.append(j)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let someDateTime = formatter.date(from: "2016/10/08 22:31")
            times.append((i.time ?? someDateTime)!)
        }
    }
    
    
    
    // gets all location data from CoreData. Location data includes name,latitude,longitude,altitude and timestamp
    private func getAllLocationHistory() -> [Location] {
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
        for i in result{
            print(i.name ?? "hi")
        }
        return result
    }

}

struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
