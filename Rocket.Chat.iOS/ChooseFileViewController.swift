//
//  ChooseFileViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 10/12/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class ChooseFileViewController: UIViewController {

    
    @IBOutlet var chooseFileAvatar: UIImageView!
    @IBOutlet var chooseFileButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chooseFileButton.backgroundColor = UIColor.rocketBlueColor()
        chooseFileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
