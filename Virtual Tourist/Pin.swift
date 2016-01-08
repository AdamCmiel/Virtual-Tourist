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
import CoreLocation

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
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
    }
    
    class func create() -> Pin {
        return NSEntityDescription.insertNewObjectForEntityForName(NAME, inManagedObjectContext: AppDelegate.managedContext) as! Pin
    }
    
    func getPhotosFromFlickr() {
        guard latitude != nil && longitude != nil else {
            fatalError("trying to get photos before setting latitude, longitude")
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
        
        fetchPhotos(location) { result in
            switch result {
            case .Success(let data):
                let photoUrls = data[PhotoURLsKey] as! [NSURL]
                var photosToReturn: [String] = []
                var foundCount = 0
                
                print(photoUrls.count)
                
                photoUrls.forEach { url in
                    PhotoFileManager.fetchFileFromNetwork(url) { result in
                        switch result {
                        case .Success(let data):
                            let photoURLString = data[PhotoFileManager.URLKey] as! String
                            
                            photosToReturn.append(photoURLString)
                            
                            self.photos = NSSet(array: photosToReturn.map {
                                let photo = Photo.create()
                                photo.diskURL = $0
                                return photo
                            })
                            
                            saveCoreData()
                            self.delegate?.photoFetcher(self, didFetchPhotoAtDiskURL: photoURLString)
                            
                            print("found photo at \(photoURLString)")
                            
                            foundCount = photosToReturn.count
                            
                            if foundCount == photoUrls.count {
                                self.delegate?.photoFetcher(self, didFetchAllPhotosForLocation: location)
                            }
                            
                        case .Failure(let error):
                            fatalError()
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
