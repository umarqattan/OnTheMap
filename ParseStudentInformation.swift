//
//  ParseStudentInformation.swift
//  OnTheMap
//
//  Created by Umar Qattan on 7/5/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation

class ParseStudentInformation {
    
    func GETStudentInformation(completionHandler: (pins: [StudentInformation]?, success: Bool, error: String?) -> Void) {
        var headers = buildHeaders()
        var request = API.getRequest(API.Parse.baseURL, api: API.Parse.Methods.studentLocation, headers: headers, queryString: [String: String]())
        var task = API.buildTask(request){ (data, error) in
            if let e = error{
                completionHandler(pins: nil, success: false, error: "Could not complete request")
            } else {
                let response = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject]
                if let error = response!["error"] as? String{
                    completionHandler(pins: nil, success: false, error: error)
                } else {
                    var pins = [StudentInformation]()
                    var results = response!["results"] as! [[String: AnyObject]]
                    for result in results {
                        pins.append(self.buildPin(result))
                    }
                    completionHandler(pins: pins, success: true, error: nil)
                }
            }
        }
    }
    
    func POSTStudentInformation(body: [String: AnyObject], completionHandler: (success: Bool, error: String?) -> Void) {
        var headers = buildHeaders()
        var request = API.postRequest(API.Parse.baseURL, api: API.Parse.Methods.studentLocation, body: body, headers: headers, queryString: [:])
        var task = API.buildTask(request) { (data, error) in
            if let e = error {
                completionHandler(success: false, error: "Could not complete request")
            } else {
                let parsedResults = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! [String: AnyObject]
                if let error = parsedResults["error"] as? String{
                    completionHandler(success: false, error: error)
                } else {
                    completionHandler(success: true, error: nil)
                }
            }
        }
    }
    
    func buildHeaders() -> [String: String] {
        return [
            API.Parse.ApplicationID.key: API.Parse.ApplicationID.value,
            API.Parse.RESTAPI.key: API.Parse.RESTAPI.value
        ]
    }
    
    func buildPin(jsonResponse: [String: AnyObject]) -> StudentInformation {
        return StudentInformation(dictionary: jsonResponse)
    }
}