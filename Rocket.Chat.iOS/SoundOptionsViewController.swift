//
//  SoundOptionsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/18/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class SoundOptionsViewController: UIViewController {
    
    
    //Labels
    @IBOutlet var newRoomNotificationLabel: UILabel!
    @IBOutlet var newMessageLabel: UILabel!

    
    //Switches
    @IBOutlet var newRoomNotificationSwitch: UISwitch!
    @IBOutlet var newMessageNotficationSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set colors to labels
        newRoomNotificationLabel.textColor = UIColor.rocketMainFontColor()
        newMessageLabel.textColor = UIColor.rocketMainFontColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Sound Options Actions
    
    @IBAction func newRoomNotificationAction(sender: AnyObject) {
        
        if newRoomNotificationSwitch.on {
            
            print("New Room Notification is ON")
            
        } else {
            
            print("New Room Notification is OFF")
            
        }
        
    }
    
    
    @IBAction func newMessageNotificationAction(sender: AnyObject) {
        
        if newMessageNotficationSwitch.on {
            
            print("New Message Notification is ON")
            
        } else {
            
            print("New Message Notification is OFF")
            
        }
        
    }

}
