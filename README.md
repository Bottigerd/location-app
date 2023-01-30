# Location App
Location app CS Comps group at Carleton College Winter 2023

## How to run

Right now, the location app runs via the simulators in Xcode: [Running your app in the simulator or on a device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

In order for the application to work as intended, a Google Maps API Key is required in `location-app/SwiftUI-UserLocation/SwiftUI-UserLocation/ContentViewModel.swift`. With location permissions, this allows the application to turn your location coordinates into an address when the "Get Address" button is pressed on the map view.