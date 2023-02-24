//  InferenceView.swift
//  This file has all of the inference made using the Core Data
//  Created by Jayti and James on 1/29/23.

import SwiftUI
import CoreData
import Foundation

//Extension to convert hex color code to RGB color
extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

//Credit to Stack Overflow: Vasily Bodnarchuk
//Extension to find difference between dates and days of week
extension Date {
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func dayNumberOfWeek(_ currDay:Date) -> Int? {
            return Calendar.current.dateComponents([.weekday], from: currDay).weekday
    }
    
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }
}

struct InferenceView: View {
    var places = [String]()
    var times = [Date]()
    let viewContext = PersistenceController.shared.container.viewContext
    
    //UI tab for Inferences
    var body: some View {
        NavigationView{
            VStack{
                if(gethome() != ""){
                    HStack{
                        Image(systemName: "house.circle.fill")
                            .foregroundColor(Color(hex: 0xfefee3, opacity: 0.8))
                            .font(.system(size: 60))
                            .offset(x: 10)
                        Spacer()
                        Text(gethome())
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    }
                    Spacer()
                }
                if (getWork() != "") {
                    HStack{
                        Image(systemName: "briefcase.circle.fill")
                            .foregroundColor(Color(hex: 0xfefee3, opacity: 0.8))
                            .font(.system(size: 60))
                            .offset(x: 10)
                        Spacer()
                        Text(getWork())
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    }
                    Spacer()
                }
                if (getTop5Locations() != ""){
                    HStack{
                        Image(systemName: "bookmark.circle.fill")
                            .foregroundColor(Color(hex: 0xfefee3, opacity: 0.8))
                            .font(.system(size: 60))
                            .offset(x: 10)
                        Spacer()
                        Text(getTop5Locations())
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    }
                    Spacer()
                }
                if (getRoutine() != ""){
                    HStack{
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(Color(hex: 0xfefee3, opacity: 0.8))
                            .font(.system(size: 60))
                            .offset(x: 10)
                        Spacer()
                        Text(getRoutine())
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    }
                }
                if (gethome() == "" && getRoutine() == "" && getWork() == "" && getTop5Locations() == ""){
                    HStack{
                        Text("Insufficient Data. Unable To Make An Inference!")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    }
                }
                Spacer()
            }
            .navigationTitle("Inferences:")
            .background( Color(hex: 0x98C9A3, opacity: 0.8))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        }
    }
    
    //Returns user's home
    private func gethome() -> String{
        //dictory to store all locations between 10pm-8am and the hours spent there
        var home = Dictionary<String, Double>()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let data = getAllLocationHistory()
    
        if (data.count == 0){
            return ""
        }
        
        var i = 0
        var originloc = data[0]
        while(i != data.count-1){
            i += 1
            if (originloc.name != data[i].name){
                let time_s = dateFormatter.string(from: originloc.time!)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]

                //Checks if hours are between 10pm and 8am OR before 10pm to next day
                if ((Int(hours.prefix(2)) ?? 0 >= 22) || (Int(hours.prefix(2)) ?? 0 <= 8) || ((Int(hours.prefix(2)) ?? 0 < 22) && (data[i].time!.distance(from: originloc.time!, only: .day) == 1)) ) {
                    let interval = data[i].time?.timeIntervalSince(originloc.time!)
                    if (home[originloc.name!] != nil) {
                        home[originloc.name ?? "Invalid location"] = home[originloc.name ?? "Invalid location"]! + (interval ?? 0.0)
                    } else {
                        home[originloc.name ?? "Invalid Location"] = interval
                    }
                    originloc = data[i]
                } else {
                    originloc = data[i]
                }
            }
        }
        
        if (home.isEmpty == true){
            return ""
        }
        
        let maxVal = home.values.max() ?? 0
        let keys = home.filter { (k, v) -> Bool in v == maxVal}.map{ (k, v) -> String in k}
        let address = "You most likely live in " +  keys[0]
        return address
    }
    
    //Returns user's place of work
    private func getWork()  -> String {
        //dictory to store all locations between 8am-5pm and the hours spent there
        var work = Dictionary<String, Double>()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let data = getAllLocationHistory();
        
        if (data.count == 0){
            return ""
        }
        
        var i = 0
        var originloc = data[0]
        while(i != data.count-1){
            i += 1
            if (originloc.name != data[i].name){
                let time_s = dateFormatter.string(from: originloc.time!)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]
                
                if ((Int(hours.prefix(2)) ?? 0 >= 8) || (Int(hours.prefix(2)) ?? 0 <= 17)) {
                    let interval = data[i].time?.timeIntervalSince(originloc.time!)
                    if (work[originloc.name!] != nil)
                    {
                        work[originloc.name ?? "Invalid location"] = work[originloc.name ?? "Invalid location"]! + (interval ?? 0.0)
                    }else {
                        work[originloc.name ?? "Invalid Location"] = interval
                    }
                    originloc = data[i]
                } else {
                    originloc = data[i]
                }
            }
        }
        
        if (work.isEmpty == true){
            return ""
        }
        
        let maxVal = work.values.max() ?? 0
        let keys = work.filter { (k, v) -> Bool in v == maxVal}.map{ (k, v) -> String in k}
        let address = "You most likely work in " +  keys[0]
        return address
    }
    
    
    //returns the 5 most frequented locations of user
    private func getTop5Locations() -> String{
        let data = getAllLocationCounts();
        print(data.count)
        if((data.count < 5) || (data[4].name == nil)){
            return ""
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
            
            var ret =  "Here Are Your Top 5 Places: \n"
            var topcount = 1
            for (place, _) in sortedVals{
                print(topcount, place)
                ret += String(topcount) + " " + place + "\n"
                topcount += 1
            }
            return ret
        }
    }
    
    //Returns Carleton users routine in the weekday according to Carleton class times
    private func getRoutine() -> String{
        let data = getAllLocationHistory();
        
        var mwTimes: Array<String> = Array();
        mwTimes = ["08:30:00", "09:50:00", "11:10:00", "12:30:00", "13:50:00", "15:10:00"];
        
        var tthTimes: Array<String> = Array();
        tthTimes = ["08:15:00", "10:10:00", "13:15:00", "15:10:00"];
        
        var fTimes: Array<String> = Array();
        fTimes = ["08:30:00", "09:40:00", "12:00:00", "13:10:00", "14:20:00", "15:30:00"];
        
        var Mon = Dictionary<[String], Int>()
        var Tues = Dictionary<[String], Int>()
        var Wed = Dictionary<[String], Int>()
        var Th = Dictionary<[String], Int>()
        var Fri = Dictionary<[String], Int>()
        
        for i in data{
            if let weekday = Date().dayNumberOfWeek(i.time!){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let time_s = dateFormatter.string(from: i.time!)
                let final_time = time_s.components(separatedBy: " ")
                let hours = final_time[1]
                
                if (weekday == 2 && mwTimes.contains(hours)){
                    let place = [i.name!, mwTimes[mwTimes.firstIndex(of: hours)!]]
                    if (Mon[place] != nil){
                        Mon[place]! += 1
                    }else{
                        print(place)
                        Mon[place] = 1
                    }
                }
                else if(weekday == 3 && tthTimes.contains(hours)){
                    let place = [i.name!, tthTimes[tthTimes.firstIndex(of: hours)!]]
                    if (Tues[place] != nil){
                        Tues[place]! += 1
                    }else{
                        Tues[place] = 1
                    }
                }
                else if(weekday == 4 && mwTimes.contains(hours)){
                    let place = [i.name!, mwTimes[mwTimes.firstIndex(of: hours)!]]
                    if (Wed[place] != nil){
                        Wed[place]! += 1
                    }else{
                        Wed[place] = 1
                    }
                }
                else if(weekday == 5 && tthTimes.contains(hours)){
                    let place = [i.name!, tthTimes[tthTimes.firstIndex(of: hours)!]]
                    if (Th[place] != nil){
                        Th[place]! += 1
                    }else{
                        Th[place] = 1
                    }
                }
                else if(weekday == 6 && fTimes.contains(hours)){
                    let place = [i.name!, fTimes[fTimes.firstIndex(of: hours)!]]
                    if (Fri[place] != nil){
                        Fri[place]! += 1
                    }else{
                        Fri[place] = 1
                    }
                }
            }
        }
        
        var mon = "This is you routine for Monday: \n"
        for (l, c) in Mon{
            if(c >= 3){
                mon += l[0] + ": " + l[1] + "\n"
            }
        }
        if (mon == "This is you routine for Monday: \n"){
            mon = ""
        }
        var tue = "This is you routine for Tuesday: \n"
        for (l, c) in Tues{
            if(c >= 3){
                tue += l[0] + ": " + l[1] + "\n"
            }
        }
        if (tue == "This is you routine for Tuesday: \n"){
            tue = ""
        }
        var wed = "This is you routine for Wednesday: \n"
        for (l, c) in Wed{
            if(c >= 3){
                wed += l[0] + ": " + l[1] + "\n"
            }
        }
        if (wed == "This is you routine for Wednesday: \n"){
            wed = ""
        }
        var thurs = "This is you routine for Thursday: \n"
        for (l, c) in Th{
            if(c >= 3){
                thurs += l[0] + ": " + l[1] + "\n"
            }
        }
        if (thurs == "This is you routine for Thursday: \n"){
            thurs = ""
        }
        var fri = "This is you routine for Friday: \n"
        for (l, c) in Fri{
            if(c >= 3){
                fri += l[0] + ": " + l[1] + "\n"
            }
        }
        if (fri == "This is you routine for Friday: \n"){
            fri = ""
        }
        let ret = mon + tue + wed + thurs + fri
        return ret
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
        return result
        
    }
    
    
}
struct InferenceView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceView()
    }
}
