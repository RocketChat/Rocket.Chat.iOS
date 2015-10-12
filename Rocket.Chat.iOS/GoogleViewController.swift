//
//  GoogleViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 10/12/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class GoogleViewController: UIViewController {

    
    @IBOutlet var googleAvatar: UIImageView!
    @IBOutlet var googleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleButton.backgroundColor = UIColor.rocketBlueColor()
        googleButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
