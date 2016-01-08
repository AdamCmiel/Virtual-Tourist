//
//  API.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/6/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import Foundation

internal typealias APICallback = APIResponse -> Void
internal typealias JSONData = [String: AnyObject]

typealias EndPoint = NSURL

enum APIErrorType {
    case Cancelled
    case Network
    case RequestJSONFormat
    case ResponseJSONFormat
    case ResponseCode
}

struct APIError {
    let errorType: APIErrorType
    let error: ErrorType?
}

enum APIResponse {
    case Success(JSONData)
    case Failure(APIError)
}

enum Method: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
}

struct API {
    static func formRawRequest(method: Method,
        _ URL: EndPoint,
        parameters: [String: AnyObject]? = nil,
        headers: [String: String]? = nil,
        completion: APICallback) {
            
        print(URL)
            
        let request = NSMutableURLRequest(URL: URL)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = method.rawValue
            
        let callback: APICallback = completion
            
        session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                callback(APIResponse.Failure(APIError(errorType: .Network, error: error!)))
                return
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            switch statusCode {
            case 200...399:
                callback(APIResponse.Success(["data": data!]))
                return
            case 0...199:
                fallthrough
            default:
                callback(APIResponse.Failure(APIError(errorType: .ResponseCode, error: nil)))
            }
        }).resume()
    }
    
    static func request(method: Method,
        _ URL: EndPoint,
        parameters: [String: AnyObject]? = nil,
        headers: [String: String]? = nil,
        completion: APICallback) {
            
        print(URL.absoluteString)
        
        let request = NSMutableURLRequest(URL: URL)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = method.rawValue
            
        let callback: APICallback = { response in
            dispatch_async(dispatch_get_main_queue(), { completion(response) })
        }
        
        do {
            
            if let params = parameters {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            }
                
            if let _headers = headers {
                for (_header, _value) in _headers {
                    request.addValue(_value, forHTTPHeaderField: _header)
                }
            }
        }
        catch (let error) {
            
            callback(APIResponse.Failure(APIError(errorType: .RequestJSONFormat, error: error)))
            return
            
        }
        
        
        session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            guard error == nil else {
                
                callback(APIResponse.Failure(APIError(errorType: .Network, error: error!)))
                return
                
            }
            
            do {
                
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                switch statusCode {
                case 200...399:
                    let dataToParse = data!
                    let json = try NSJSONSerialization.JSONObjectWithData(dataToParse, options: [.MutableLeaves, .AllowFragments]) as! JSONData
                    callback(APIResponse.Success(json))
                    return
                case 0...199:
                    fallthrough
                default:
                    callback(APIResponse.Failure(APIError(errorType: .ResponseCode, error: nil)))
                }
                
            }
            catch (let JSONError) {
                
                callback(APIResponse.Failure(APIError(errorType: .ResponseJSONFormat, error: JSONError)))
                return
                
            }
            
        }).resume()
    }
    
    static func get(endpoint: EndPoint, completion: APICallback) {
        return request(.GET, endpoint, parameters: nil, headers: nil, completion: completion)
    }

    static func getData(endpoint: EndPoint, completion: APICallback) {
        return formRawRequest(.GET, endpoint, parameters: nil, headers: nil, completion: completion)
    }
}