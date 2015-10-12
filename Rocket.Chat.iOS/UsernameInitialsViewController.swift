//
//  UsernameInitialsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 10/12/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class UsernameInitialsViewController: UIViewController {

    
    @IBOutlet var usernameAvatar: UIImageView!
    @IBOutlet var usernameInitialsButton: UIButton!
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameInitialsButton.backgroundColor = UIColor.rocketBlueColor()
        usernameInitialsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
