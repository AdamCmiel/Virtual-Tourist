//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {
// Insert code here to add functionality to your managed object subclass
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        let managedContext = AppDelegate.managedContext
        for photo in photos! {
            let p = photo as! Photo
            managedContext.deleteObject(managedContext.objectWithID(p.objectID))
        }
    }
}
