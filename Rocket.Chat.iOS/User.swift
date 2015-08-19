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
    enum Status : Int16{
        case ONLINE = 0
        case AWAY = 1
        case BUSY = 2
        case INVISIBLE = 3
    }
    
    @NSManaged dynamic var id : String
    @NSManaged dynamic var username : String
    @NSManaged dynamic var password : String? //Password is only for the local user, not remote
    
    /// Avatar url or image name.
    /// In case this is not a url the code calling must know how to construct the url
    @NSManaged dynamic var avatar : String
    /// This is to make CoreData work, since it doesn't support enums
    /// We store this private int to CoreData and use `status` for public usage
    @NSManaged dynamic private var statusVal : NSNumber
    var status : Status {
        get {
            return Status(rawValue: statusVal.shortValue) ?? .ONLINE
        }
        set {
            //self.statusVal = NSNumber(short: newValue.rawValue)
            setValue(NSNumber(short: newValue.rawValue), forKey: "statusVal")
        }
    }
    @NSManaged dynamic var statusMessage : String?
    
    @NSManaged dynamic private var timezoneVal : String
    var timezone : NSTimeZone {
        get {
            return NSTimeZone(name: timezoneVal) ?? NSTimeZone.systemTimeZone()
        }
        set {
            self.timezoneVal = newValue.name
        }
    }

    convenience init(context: NSManagedObjectContext, id:String, username:String, avatar:String, status : Status, timezone : NSTimeZone){
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.username = username
        self.avatar = avatar
        //TODO: Setting status hear will cause an exception, come back later and check why (probably swift/compiler bug)
        //self.status = status
        setValue(NSNumber(short: status.rawValue), forKey: "statusVal")
        self.timezoneVal = timezone.name
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
