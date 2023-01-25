//
//  main.swift
//  SwiftUI-UserLocation
//
//  Created by CS Lab Account on 1/24/23.
//

import Foundation




func readFile(){
    errno = 0
    let path = "dataset.txt"
    if freopen(path, "r",stdin) == nil {
        perror(path)
    }
    while let line = readLine() {
        print(line)
    }

}


readFile()
