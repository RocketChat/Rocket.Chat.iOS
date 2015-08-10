//
//  User.swift
//  Rocket.Chat.iOS
//
//  Created by Mobile Apps on 8/5/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import Foundation
import CoreData

class User : NSManagedObject {
    /// Status of the `User`
    /// This uses raw values, in order to facilitate CoreData
    enum Status : Int{
        case ONLINE = 0
        case AWAY = 1
        case BUSY = 2
        case INVISIBLE = 3
    }
    
    @NSManaged var id : String
    @NSManaged var username : String
    @NSManaged var password : String? //Password is only for the local user, not remote
    
    /// Avatar url or image name.
    /// In case this is not a url the code calling must know how to construct the url
    @NSManaged var avatar : String
    /// This is to make CoreData work, since it doesn't support enums
    /// We store this private int to CoreData and use `status` for public usage
    @NSManaged private var statusVal : Int
    var status : Status {
        get {
            return Status(rawValue: statusVal)!
        }
        set {
            self.statusVal = newValue.rawValue
        }
    }
    @NSManaged var statusMessage : String?
    
    @NSManaged var timezone : NSTimeZone

    init(context: NSManagedObjectContext, id:String, username:String, avatar:String, status : Status, timezone : NSTimeZone){
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.username = username
        self.avatar = avatar
        self.status = status
        self.timezone = timezone
    }
    
    //For Hashable
    override var hashValue : Int {
        return id.hashValue
    }
}

//For Equalable (part of Hashable)
func == (left : User, right: User) -> Bool {
    return left.id == right.id
}
