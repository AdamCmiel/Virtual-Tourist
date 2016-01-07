//
//  Data.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

private extension AppDelegate {
    class var managedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
}

class Pin: NSObject, MKAnnotation {
    let latitude: Double
    let longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func save() throws {
        let managedContext = AppDelegate.managedContext
        let entity =  NSEntityDescription.entityForName("Pin",
            inManagedObjectContext:managedContext)
        let pin = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        pin.setValue(latitude, forKey: "latitude")
        pin.setValue(longitude, forKey: "longitude")
        
        try managedContext.save()
    }
    
    @objc var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

