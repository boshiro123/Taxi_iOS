//
//  LocationManager.swift
//  Taxi_3
//
//  Created by shirokiy on 05/10/2023.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject{
    
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func getCurrentLocation()-> CLLocation{
        return currentLocation ?? CLLocation(latitude: 0, longitude: 0)
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        if let location = locations.last {
            currentLocation = location
            print("__________\(currentLocation)")
            locationManager.stopUpdatingLocation()
        }
    }
}
