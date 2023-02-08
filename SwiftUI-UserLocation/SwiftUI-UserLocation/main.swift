//
//  main.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/24/23.
//

import Foundation




//func readFile(){
//    errno = 0
//    let path = "dataset.txt"
//    if freopen(path, "r",stdin) == nil {
//        perror(path)
//    }
//    while let line = readLine() {
//        print(line)
//    }
//
//}

//create dictionary  Key -> Place , Val -> # of hours you're there
//for loop - iterate through until 10:00 pm, add place to dict, if same
//place in next line, increase counter in val, else add new place to dict
//return biggest Key,Val pair

func gethome(){
    var home = Dictionary<String, Int>()
    errno = 0
    let path = "dataset.txt"
    if freopen(path, "r",stdin) == nil {
        perror(path)
    }
    while let line = readLine() {
        let location = line.components(separatedBy: ",")
        let time: String = location[0]
        let place: String = location[1]
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
    print("You most likely live in", keys[0])
    
    
    
}



gethome()
