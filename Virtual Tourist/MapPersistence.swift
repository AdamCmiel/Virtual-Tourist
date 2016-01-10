//
//  MapPersistence.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/9/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import MapKit
import Foundation
import CoreLocation

struct MapPersistence {
    static let regionKey = "mapViewPersistentRegion"
    static let longitudeKey = "longitude"
    static let latitudeKey = "latitude"
    static let latDeltaKey = "latDelta"
    static let lonDeltaKey = "lonDelta"
    
    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167) // san francisco
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    
    static var debouncedSetRegion = debounce(0.3, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action: MapPersistence._setRegion)
    
    private static func _setRegion(region: Any) {
        let r = region as! MKCoordinateRegion
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let defaults = NSUserDefaults.standardUserDefaults()
            let longitude = NSNumber(double: r.center.longitude)
            let latitude = NSNumber(double: r.center.latitude)
            let latDelta = NSNumber(double: r.span.latitudeDelta)
            let lonDelta = NSNumber(double: r.span.longitudeDelta)
            
            let regionDict = [
                longitudeKey: longitude,
                latitudeKey: latitude,
                latDeltaKey: latDelta,
                lonDeltaKey: lonDelta
            ]
            
            defaults.setObject(regionDict, forKey: regionKey)
        }
    }
    
    static var region: MKCoordinateRegion {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let regionDict = defaults.objectForKey(regionKey) as? NSDictionary {
                let longitude = regionDict[longitudeKey] as! NSNumber
                let latitude = regionDict[latitudeKey] as! NSNumber
                let latDelta = regionDict[latDeltaKey] as! NSNumber
                let lonDelta = regionDict[lonDeltaKey] as! NSNumber
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                let span = MKCoordinateSpan(latitudeDelta: latDelta.doubleValue, longitudeDelta: lonDelta.doubleValue)
                return MKCoordinateRegion(center: coordinate, span: span)
            } else {
                return MKCoordinateRegion(center: defaultLocation, span: defaultSpan)
            }
        }
        set (r) {
            debouncedSetRegion(r)
        }
    }
    
    static var annotations: [Pin] {
        return Pin.all()
    }
}

// debounce method from http://stackoverflow.com/questions/27116684/how-can-i-debounce-a-method-call
func debounce(delay:NSTimeInterval, queue:dispatch_queue_t, action: (Any->()) ) -> Any->() {
    var lastFireTime:dispatch_time_t = 0
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
    
    return { param in
        lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            queue) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(lastFireTime, dispatchDelay)
                if now >= when {
                    action(param)
                }
        }
    }
}