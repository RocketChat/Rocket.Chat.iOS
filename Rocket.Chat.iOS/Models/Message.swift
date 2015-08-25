//
//  Message.swift
//  Rocket.Chat.iOS
//
//  Created by Mobile Apps on 8/5/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import Foundation

class Message: Hashable, Comparable{
    /// Id of the message
    var id: String
    /// Actual content of the message, non formated
    var text: String
    /// Date-time at which message was sent
    var tstamp : NSDate
    /// The `User` that sent the message
    var user : User
    
    init(id: String, text: String, tstamp: NSDate, user:User){
        self.id = id
        self.text = text
        self.tstamp = tstamp
        self.user = user
    }
    
    //For Hashable
    var hashValue : Int {
        return id.hashValue
    }
}

//For Equalable (part of Hashable)
func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}
//For Comparable (other comparisons are derived from == and < )
func <(lhs: Message, rhs: Message) -> Bool{
    var res = lhs.tstamp.compare(rhs.tstamp) == NSComparisonResult.OrderedAscending
    if !res {
        res = lhs.id < rhs.id
    }
    return res
}
