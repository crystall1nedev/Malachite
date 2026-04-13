//
//  Location.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/17/26.
//

import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    /// An instance of ``MalachiteClassesObject`` for use in this class and its children.
    var utilities: MalachiteClassesObject
    
    public var location = CLLocationManager()
    
    public var locationEnabled: Bool {
        get {
            if utilities.versionType != "INTERNAL" { return false }
            
            return location.authorizationStatus == .authorizedWhenInUse
        }
    }
    
    init(
        utilities: MalachiteClassesObject
    ) {
        self.utilities = utilities
        super.init()
        
        self.location.delegate = self
        self.location.desiredAccuracy = kCLLocationAccuracyBest
        self.location.requestWhenInUseAuthorization()
    }
    
    public func startLocationServices() {
        self.location.startUpdatingLocation()
        self.location.startUpdatingHeading()
    }
}
