//
//  API.swift
//  OnTheMap
//
//  Created by Umar Qattan on 7/4/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation


    /**
        MARK: An API class that contains information about both Parse
              and Udacity APIs.
    **/

class API {
    
    struct Parse {
        
        struct ApplicationID {
            static let key = "X-Parse-Application-Id"
            static let value = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        }
        
        struct RESTAPI {
            static let key = "X-Parse-REST-API-Key"
            static let value = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        struct Methods {
            
            static let studentLocation = "1/classes/StudentLocation?limit=100"
            
        }
        static let baseURL = "https://api.parse.com/"
        
    }
    
    struct Udacity {
        
        struct Methods {
            static let session = "api/session"
            static let userInfo = "api/users/{id}"
        }
        
        struct Request {
            static let body = [
                "udacity" : [
                    "username" : "",
                    "password" : ""
                ]
            ]

        }
        
        static let baseURL = "https://www.udacity.com/"
    
    }
    
    struct HTTP {
        
        struct Request {
            static let value = "Content-Type"
            static let key = "Accept"
        }
        
        struct Methods {
            static let POST = "POST"
            static let GET = "GET"
        }
        
    }
    
    static let jsonValue = "application/json"
    static let session = NSURLSession.sharedSession()
    
    /**
        MARK: API REST helper methods that build a task from either a get or a post 
              request, which is made from a url built with an API method and an optional
              query.
    **/
    
    static func buildTask(request : NSMutableURLRequest, completionHandler : (result : NSData!, error : NSError?) -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: data, error: nil)
            }
        }
        task.resume()
        return task
    }
    
    static func getRequest(baseURL : String, api : String, headers : [String : String], queryString : [String : String]) -> NSMutableURLRequest {
        let url = buildURL(baseURL, api: api, queryString: queryString)
        let request = NSMutableURLRequest(URL: url)
        request.addValue(jsonValue, forHTTPHeaderField: HTTP.Request.key)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
    
    static func postRequest(baseURL : String, api : String, body : [String : AnyObject], headers : [String : String], queryString : [String : String]) -> NSMutableURLRequest {
        var parsingError : NSError? = nil
        let request = getRequest(baseURL, api: api, headers: headers, queryString: queryString)
        request.HTTPMethod = HTTP.Methods.POST
        request.addValue(jsonValue, forHTTPHeaderField: HTTP.Request.value)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &parsingError)
        return request
    }
    
    static func buildURL(baseURL : String, api : String, queryString : [String : String]) -> NSURL {
        let urlString = baseURL + api + escapedParameters(queryString)
        return NSURL(string: urlString)!
    }
    
    static func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
}