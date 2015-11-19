//
//  DarwinNotifications.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 11/19/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import Foundation

func displayStatusChanged(center: CFNotificationCenter!, _: UnsafeMutablePointer<Void>, name: CFString!, _: UnsafePointer<Void>, userInfo: CFDictionary!){
    
    if (name == "com.apple.springboard.lockcomplete") {
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kDisplayStatusLocked")
        
    }
    
}