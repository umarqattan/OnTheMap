//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Umar Qattan on 7/4/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var firstName : String?
    var lastName : String?
    var latitude : Double?
    var longitude : Double?
    var mapString : String?
    var mediaURL : String?
    var objectID : String?
    var uniqueKey : String?
    
    init(dictionary : [String : AnyObject]) {
        
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        if let objectID = dictionary["objectID"] as? String {
            self.objectID = objectID
        }
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
    }

}
