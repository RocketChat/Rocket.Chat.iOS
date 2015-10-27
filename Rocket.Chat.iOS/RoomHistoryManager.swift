////
////  RoomHistoryManager.swift
////  Rocket.Chat.iOS
////
////  Created by Kornelakis Michael on 10/15/15.
////  Copyright © 2015 Rocket.Chat. All rights reserved.
////
//
//import UIKit
//import ObjectiveDDP
//
//class RoomHistoryManager  {
//    
//    var meteor:MeteorClient
//    
//    init(meteor:MeteorClient) {
//        
//        self.meteor = meteor
//        
//    }
//    
//    let defaultLimit = 50
//    
//    var histories:NSDictionary
//    
//    
//    func getMoreIfIsEmpty(roomId: String) {
//        var room:NSDictionary
//        
//        room = getRoom(roomId)
//        
//    if (room["loaded"] != nil) {
//    
//            getMore(roomId, limit: defaultLimit)
//            
//        }
//        
//    }
//    
//    
//    func getMore(roomId: String, limit: Int) {
//        var room:NSDictionary
//        
//        room = getRoom(roomId)
//        
//        let roomHasMore:Bool = room["hasMore"] as! Bool
//        if roomHasMore != true {
//            return
//        }
//        
//        
//        room["isLoading"] = true
//        
//        //TODO find lastMessage from ChatMessage collection
//        let lastMessage:Message
//        
//        
//        
//        
//        
//        
//    }
//    
//    
//    func getRoom(roomId: String) -> NSDictionary {
//     
//        if histories.count == 0 {
//            
//            histories = [
//                "hasMore": true,
//                "isLoading": false,
//                "unreadNotLoaded": 0,
//                "loaded": 0
//            ]
//            
//        }
//       
//        return histories
//        
//    }
//    
//    
//}
