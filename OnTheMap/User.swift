//
//  User.swift
//  OnTheMap
//
//  Created by Umar Qattan on 7/4/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation

struct User {
    
    var id : String!
    var key : String!
    var firstName : String!
    var lastName : String!
    
    init(dictionary : [String : AnyObject]) {
        if let session = dictionary["session"] as? [String : AnyObject] {
            if let account = dictionary["account"] as? [String : AnyObject] {
                self.id = session["id"] as! String
                self.key = account["key"] as! String
            }
        }
    }
}
