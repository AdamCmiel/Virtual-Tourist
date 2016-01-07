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

class _Pin: NSObject, MKAnnotation {
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

protocol PhotoFetcherDelegate {
    func photoFetcher(photoFetcher: PhotoFetcher, didFetchPhotoURLs: [NSURL])
    func photoFetcher(photoFetcher: PhotoFetcher, failedToFetchPhotos: AnyObject?)
}

struct PhotoFetcher {
    
    let delegate: PhotoFetcherDelegate
    func fetchPhotos(coordinate: CLLocationCoordinate2D) {
        let endPoint = NSBundle.mainBundle().infoDictionary!["FlickrAPIEndpoint"] as! String
        let queryDict = NSBundle.mainBundle().infoDictionary!["FlickrAPIQuery"] as! NSDictionary
        
        let mutableQueryDict = NSMutableDictionary(dictionary: queryDict)
        mutableQueryDict["lat"] = "\(coordinate.latitude)"
        mutableQueryDict["lon"] = "\(coordinate.longitude)"
        
        let components = NSURLComponents(string: endPoint)!
        components.queryItems = mutableQueryDict.flatMap { (key, value) in
            return NSURLQueryItem(name: key as! String, value: value as? String)
        }
        
        let URL = components.URL!
        API.get(URL) { result in
            switch result {
            case .Success(let data):
                let photoURLs: [String] = ((data["photos"] as! JSONData)["photo"] as! Array<JSONData>).map { data in
                    let id = data["id"] as! String
                    let farm = data["farm"] as! String
                    let server = data["server"] as! String
                    let secret = data["secret"] as! String
                    return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
                }
                let URLs = photoURLs.map { return NSURL(string: $0)! }
                self.delegate.photoFetcher(self, didFetchPhotoURLs: URLs)
            case .Failure(let error):
                self.delegate.photoFetcher(self, failedToFetchPhotos: nil)
            }
        }
    }
}

struct PhotoFileManager {
    static func fetchFileFromNetwork(URL: NSURL) {
        API.getData(URL) { result in
            switch result {
            case .Success(let data):
                let fileData: NSData = data["data"] as! NSData
                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                if let image = UIImage(data: fileData) {
                    let fileURL = documentsURL.URLByAppendingPathComponent(URL.path!)
                    if let jpegRepresentation = UIImageJPEGRepresentation(image, 0.8) {
                        jpegRepresentation.writeToURL(fileURL, atomically: false)
                    }
                }
                break
            case .Failure(let error):
                break
            }
        }
    }
    
    static func removeFileFromDisc(URL: NSURL) throws {
        try NSFileManager.defaultManager().removeItemAtURL(URL)
    }
}

