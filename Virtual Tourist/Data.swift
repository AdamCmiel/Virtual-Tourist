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

func saveCoreData() {
    do {
        try AppDelegate.managedContext.save()
    } catch let error {
        fatalError("could not save pin \(error)")
    }
}

let PhotoURLsKey = "urls"
func fetchPhotos(coordinate: CLLocationCoordinate2D, callback: APICallback) {
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
                let farm = data["farm"] as! Int
                let server = data["server"] as! String
                let secret = data["secret"] as! String
                return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
            }
            let URLs = photoURLs.map { return NSURL(string: $0)! }
            callback(.Success([PhotoURLsKey: URLs]))
        case .Failure(let error):
            callback(.Failure(error))
        }
    }
}

struct PhotoFileManager {
    
    static let URLKey = "url"
    
    static func fetchFileFromNetwork(URL: NSURL, callback: APICallback) {
        API.getData(URL) { result in
            switch result {
            case .Success(let data):
                let fileData: NSData = data["data"] as! NSData
                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                if let image = UIImage(data: fileData) {
                    let fileURL = documentsURL.URLByAppendingPathComponent(URL.path!)
                    if let jpegRepresentation = UIImageJPEGRepresentation(image, 0.8) {
                        jpegRepresentation.writeToURL(fileURL, atomically: true)
                        callback(.Success([PhotoFileManager.URLKey: fileURL]))
                    }
                }
            case .Failure(let error):
                callback(.Failure(error))
            }
        }
    }
    
    static func removeFileFromDisc(URL: NSURL) throws {
        try NSFileManager.defaultManager().removeItemAtURL(URL)
    }
}

