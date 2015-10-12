//
//  FacebookViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 10/12/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class FacebookViewController: UIViewController {

    
    @IBOutlet var facebookAvatar: UIImageView!
    @IBOutlet var facebookButton: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        facebookButton.backgroundColor = UIColor.rocketBlueColor()
        facebookButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
