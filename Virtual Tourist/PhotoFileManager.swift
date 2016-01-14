//
//  Data.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import class UIKit.UIImage
import struct CoreLocation.CLLocationCoordinate2D

func saveCoreData() {
    do {
        try AppDelegate.managedContext.save()
    } catch let error {
        fatalError("could not save pin \(error)")
    }
}

struct PhotoFileManager {
    
    static let sharedManager = PhotoFileManager()
    
    static let URLKey = "url"
    static let PhotoURLsKey = "urls"
    
    let fileManager = NSFileManager.defaultManager()
    let cache = ImageCache()
    
    func fetchPhotos(coordinate: CLLocationCoordinate2D, page: Int, callback: APICallback) {
        let endPoint = NSBundle.mainBundle().infoDictionary!["FlickrAPIEndpoint"] as! String
        let queryDict = NSBundle.mainBundle().infoDictionary!["FlickrAPIQuery"] as! NSDictionary
        
        let mutableQueryDict = NSMutableDictionary(dictionary: queryDict)
        mutableQueryDict["lat"] = "\(coordinate.latitude)"
        mutableQueryDict["lon"] = "\(coordinate.longitude)"
        mutableQueryDict["page"] = "\(page)"
        
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
                callback(.Success([PhotoFileManager.PhotoURLsKey: URLs]))
            case .Failure(let error):
                callback(.Failure(error))
            }
        }
    }
    
    func fetchFileFromNetwork(URL: NSURL, callback: APICallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            API.getData(URL) { result in
                switch result {
                case .Success(let data):
                    let fileData: NSData = data["data"] as! NSData
                    if let image = UIImage(data: fileData) {
                        let imagePathURL = URL.path!.stringByReplacingOccurrencesOfString("/", withString: "_")
                        let didWrite = self.cache.storeImage(image, withIdentifier: imagePathURL)
                        
                        if (!didWrite) {
                            fatalError("did not write photo to disk")
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            callback(.Success([PhotoFileManager.URLKey: imagePathURL]))
                        }
                            
                        return
                    }
                    
                    let error = NSError(domain: "could not decode data", code: 1, userInfo: nil)
                    let returnError = APIError(errorType: .ResponseCode, error: error)
                    callback(.Failure(returnError))
                case .Failure(let error):
                    callback(.Failure(error))
                }
            }
        }
    }
    
     func fetchFileFromDisc(urlString: String) -> UIImage? {
        return cache.imageWithIdentifier(urlString)!
    }
    
     func removeFileFromDisc(path: String) {
        let didSave = cache.storeImage(nil, withIdentifier: path)
        if !didSave {
            fatalError("did not remove file from disk")
        }
    }
    
     func URLOnDisk(path: String) -> NSURL {
        let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return documentsURL.URLByAppendingPathComponent(path)
    }
}