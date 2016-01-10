//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    static let NAME = "Photo"
    
    class func create() -> Photo {
        return NSEntityDescription.insertNewObjectForEntityForName(NAME, inManagedObjectContext: AppDelegate.managedContext) as! Photo
    }

    override func prepareForDeletion() {
        super.prepareForDeletion()
        PhotoFileManager.sharedManager.removeFileFromDisc(diskURL!)
    }

}
