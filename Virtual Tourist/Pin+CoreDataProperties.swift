//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var hasFetchedPhotos: NSNumber?
    @NSManaged var page: NSNumber?
    @NSManaged var photos: NSSet?
    
    @NSManaged func addPhotos(photos: NSSet)
    @NSManaged func removePhotos(photos: NSSet)
}
