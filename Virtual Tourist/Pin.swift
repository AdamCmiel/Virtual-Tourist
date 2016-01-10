//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import MapKit
import CoreData
import Foundation
import struct CoreLocation.CLLocationCoordinate2D

protocol Fetcher {}
protocol PhotoReciever {
    func photoFetcher(fetcher: Fetcher, didFetchPhotoAtDiskURL: String)
    func photoFetcher(fetcher: Fetcher, didFetchAllPhotosForLocation: CLLocationCoordinate2D)
}

class Pin: NSManagedObject, MKAnnotation, Fetcher {
// Insert code here to add functionality to your managed object subclass
    
    static let PhotosKey = "photos"
    static let NAME = "Pin"
    
    var delegate: PhotoReciever?
    
    var _hasFetchedAllPhotos = false
    
    var hasFetchedAllPhotos: Bool {
        get { return Bool(hasFetchedPhotos!) }
        set(h) {
            hasFetchedPhotos = h
            saveCoreData()
        }
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
    }
    
    class func create() -> Pin {
        return NSEntityDescription.insertNewObjectForEntityForName(NAME, inManagedObjectContext: AppDelegate.managedContext) as! Pin
    }
    
    class func all() -> [Pin] {
        let context = AppDelegate.managedContext
        let request = NSFetchRequest(entityName: "Pin")
        
        do {
            return try context.executeFetchRequest(request) as! [Pin]
        } catch let error {
            print(error)
            return []
        }
    }
    
    func getPhotosFromFlickr() {
        hasFetchedAllPhotos = false
        
        guard latitude != nil && longitude != nil else {
            fatalError("trying to get photos before setting latitude, longitude")
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
        
        PhotoFileManager.sharedManager.fetchPhotos(location) { result in
            switch result {
            case .Success(let data):
                let photoUrls = data[PhotoFileManager.PhotoURLsKey] as! [NSURL]
                var photosToReturn: [String] = []
                var foundCount = 0
                var closureCount = 0
                
                print(photoUrls.count)
                
                photoUrls.forEach { url in
                    PhotoFileManager.sharedManager.fetchFileFromNetwork(url) { result in
                        closureCount++
                        
                        switch result {
                        case .Success(let data):
                            let photoURLString = data[PhotoFileManager.URLKey] as! String
                            
                            photosToReturn.append(photoURLString)
                            
                            
                            self.delegate?.photoFetcher(self, didFetchPhotoAtDiskURL: photoURLString)
                            
                            print("found photo at \(photoURLString)")
                            
                            
                        case .Failure(let error):
                            fatalError()
                        }
                        
                        if closureCount == photoUrls.count {
                            foundCount = photosToReturn.count
                            
                            if foundCount == photoUrls.count {
                                self.delegate?.photoFetcher(self, didFetchAllPhotosForLocation: location)
                                self.hasFetchedAllPhotos = true
                            }
                            
                            self.photos = NSSet(array: photosToReturn.map {
                                let photo = Photo.create()
                                photo.diskURL = $0
                                return photo
                            })
                            saveCoreData()
                        }
                    }
                }
                
            case .Failure(let error):
                fatalError()
            }
        }
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        let managedContext = AppDelegate.managedContext
        for photo in photos! {
            let p = photo as! Photo
            managedContext.deleteObject(managedContext.objectWithID(p.objectID))
        }
    }
}
