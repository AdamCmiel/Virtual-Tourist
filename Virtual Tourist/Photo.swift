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

    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        if let urlString = diskURL {
            if let URL = NSURL(string: urlString) {
                do {
                    try PhotoFileManager.removeFileFromDisc(URL)
                } catch let error {
                    print("could not delete photo at url \(URL, urlString, error)")
                }
            }
        }
    }

}
