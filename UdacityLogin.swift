//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Umar Qattan on 7/4/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit

class UdacityLogin {

    
    /**
        MARK: methods to ensure secure authentication with Udacity and receipt of user
              information (i.e. userID, sessionID, and name).
    **/
    func secureLogin(email : String, password : String, completionHandler : (success : Bool, error : String?) -> Void) {
        var body = getBody(email, password: password)
        var headers = [String : String]()
        var queryString = [String : String]()
        var request = API.postRequest(API.Udacity.baseURL, api: API.Udacity.Methods.session, body: body, headers: headers)
        let task = API.buildTask(request) { data, downloadError in
            if let error = downloadError {
                completionHandler(success: false, error: "Could not complete login request")
            } else {
                var parsingError : NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                let parsedResults = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String : AnyObject]
                if let errorMessage = parsedResults["error"] as? String {
                    completionHandler(success: false, error: errorMessage)
                } else {
                    self.setUser(parsedResults)
                    completionHandler(success: true, error: nil)
                }
            }
        }
    }
    
    func getUserInformation(userID : String, completionHandler : (success : Bool, error : String?) -> Void) {
        var headers = [String : String]()
        var queryString = [String : String]()
        
        /**
            Source:
        **/
        let api = API.Udacity.Methods.userInfo.stringByReplacingOccurrencesOfString("{id}", withString: userID, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var request = API.getRequest(API.Udacity.baseURL, api: api, headers: headers)
        let task = API.buildTask(request) { data, downloadError in
            if let error = downloadError {
                completionHandler(success: false, error: "Could not complete session request")
            } else {
                var parsingError : NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                let parsedResults = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String : AnyObject]
                if let errorMessage = parsedResults["error"] as? String {
                    completionHandler(success: false, error: errorMessage)
                } else {
                    self.updateUser(parsedResults)
                    completionHandler(success: true, error: nil)
                }
            }
        }
    }
    
    func getBody(email : String, password : String) -> [String : AnyObject] {
        return [
                "udacity" : [
                    "username" : email,
                    "password" : password
                ]
            ]
    }
    
    func saveUserInformation(user: User) {
        getAppDelegate().user = user
    }
    
    func updateUser(response : [String : AnyObject]) {
        var user = getAppDelegate().user
        if let userResponse = response["user"] as? [String : AnyObject] {
            user?.firstName = userResponse["first_name"] as! String
            user?.lastName = userResponse["last_name"] as! String
            saveUserInformation(user!)
        }
    }
    
    func setUser(response : [String : AnyObject]) {
        saveUserInformation(User(dictionary: response))
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}