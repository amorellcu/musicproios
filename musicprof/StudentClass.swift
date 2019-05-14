//
//  StudentClass.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

public class Student {
    var email: String?
    var name: String?
    var fbid: String?
    var photo: UIImage?
    var phone: String?
    var urlphoto: String?
    
    public func AutoCompleteFace(faceVariables:[String : AnyObject]!){
        print(faceVariables)
    
    }
    
    public func setName(aname:String){
        self.name = aname
    }
    
    public func getName()->String{
        return self.name!
    }
    
    public func setEmail(aemail:String){
        self.email = aemail
    }
    
    public func getEmail()->String{
        return self.email!
    }
    
    public func setPhoto(aphoto:UIImage?){
        self.photo = aphoto
    }
    
    public func getPhoto()->UIImage?{
        return self.photo!
    }
    
    public func getFbId()->String{
        return self.fbid!
    }
    
    public func setFbId(afbid:String){
        self.fbid = afbid
    }
    
    public func setPhone(aphone:String){
        self.phone = aphone
    }
    
    public func getPhone()->String{
        return self.phone!
    }
    
    public func setUrlPhoto(aurlphoto:String){
        self.urlphoto = aurlphoto
    }
    
    public func getUrlPhoto()->String{
        return ((self.urlphoto) != nil) ? self.urlphoto! : ""
    }
    
    
}


