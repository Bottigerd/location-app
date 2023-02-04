//
//  InferenceView.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/29/23.
//

import SwiftUI
import CoreData

struct InferenceView: View {
    
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
        errno = 0
        //ISSUE:
        let path = "dataset.txt"
        if freopen(path, "r",stdin) == nil {
            perror(path)
        }
        while let line = readLine() {
            let location = line.components(separatedBy: ",")
            print("location: ", location)
            let time: String = location[0]
            print("time: ", time)
            let place: String = location[1]
            print("place: ", place)
            let final_time = time.components(separatedBy: " ")
            //The one we want
            let clock: String = final_time[1]

            if ((Int(clock.prefix(2)) ?? 0 >= 22) || (Int(clock.prefix(2)) ?? 0 <= 6) ) {
                var count = home[place] ?? 0
                count = count + 1
                home[place] = count
            }
        }
        //print(home.values.max() ?? 0)
        let maxVal = home.values.max() ?? 0
        let keys = home.filter { (k, v) -> Bool in v == maxVal}.map{ (k, v) -> String in k}
        //Since file is not read yet, keys is empty and won't print anything
        //let address = "You most likely live in " + keys[0]
        let address = "HOME: Cassat"
        return address

    }
    
    
    
    // gets all location data from CoreData. Location data includes name,latitude,longitude,altitude and timestamp
    private func getAllLocationHistory() -> [Location] {
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let result = try! viewContext.fetch(fetchRequest) as! [Location]
        return result
    }

}

struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
