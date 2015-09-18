//
//  MessagesOptionsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/18/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class MessagesOptionsViewController: UIViewController {

    @IBOutlet var useEmojisLabel: UILabel!
    @IBOutlet var convertAsciiToEmojiLabel: UILabel!
    @IBOutlet var autoLoadImagesLabel: UILabel!
    @IBOutlet var saveMobileBandWidthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set color to labels
        useEmojisLabel.textColor = UIColor.rocketMainFontColor()
        convertAsciiToEmojiLabel.textColor = UIColor.rocketMainFontColor()
        autoLoadImagesLabel.textColor = UIColor.rocketMainFontColor()
        saveMobileBandWidthLabel.textColor = UIColor.rocketMainFontColor()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
