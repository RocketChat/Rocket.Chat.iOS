//
//  ChatRoom.swift
//  Rocket.Chat.iOS
//
//  Created by Mobile Apps on 8/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import Foundation

class ChatRoom:Hashable{
    
    /// Type of chat room
    enum Type {
        /// Public room (everyone can join)
        case PUBLIC
        /// IM, only between two users
        case IM
        /// Private room (invitation only)
        case PRIVATE
    }
    
    /// Used to store number of unread messages and date since messages are unread
    struct UnreadCounter{
        /// Number of unread messages
        var count : Int
        /// Since when there are unread messages
        var since : NSDate
    }
    
    /// Unique id of the room
    var id : String
    /// Displayed name of the room
    var name : String
    /// `User`s participating in the room
    var users : Set<User>
    /// `Message`s in the room
    var messages : Set<Message>//TODO: Change to orderer array, to preserve sending order
    /// `Type` of room
    var type : Type
    /// Unread counter and unread since date
    var unread : UnreadCounter?
    /// Users that are currently typing
    var typing : [User]?
    
    init(id:String, name: String, type: Type, users:Set<User>, messages:Set<Message>){
        self.id = id
        self.name = name
        self.users = users
        self.messages = messages
        self.type = type
    }
    
    convenience init(id:String, name: String, type : Type){
        self.init(id:id, name:name, type:type, users:Set<User>(), messages:Set<Message>())
    }
    
    // For Hashable
    var hashValue: Int {
        return id.hashValue
    }
}

//For Equalable (part of Hashable)
func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
    return lhs.id == rhs.id
}