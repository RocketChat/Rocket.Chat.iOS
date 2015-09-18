//
//  SoundOptionsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/18/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class SoundOptionsViewController: UIViewController {
    
    @IBOutlet var newRoomNotificationLabel: UILabel!
    @IBOutlet var newMessageLabel: UILabel!

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


}
