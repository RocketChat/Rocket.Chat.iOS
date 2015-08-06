//
//  User.swift
//  Rocket.Chat.iOS
//
//  Created by Mobile Apps on 8/5/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import Foundation

class User : Hashable {
    enum Status {
        case ONLINE
        case AWAY
        case BUSY
        case INVISIBLE
    }
    
    var id : String
    var username : String
    var password : String? = nil //Password is only for the local user, not remote
    
    /// Avatar url or image name.
    /// In case this is not a url the code calling must know how to construct the url
    var avatar : String
    var status : Status
    var statusMessage : String?
    
    var timezone : NSTimeZone

    init(id:String, username:String, avatar:String, status : Status, timezone : NSTimeZone){
        self.id = id
        self.username = username
        self.avatar = avatar
        self.status = status
        self.timezone = timezone
    }
    
    //For Hashable
    var hashValue : Int {
        return id.hashValue
    }
}

//For Equalable (part of Hashable)
func == (left : User, right: User) -> Bool {
    return left.id == right.id
}
