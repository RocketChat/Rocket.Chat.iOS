//
//  MessagesOptionsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/18/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class MessagesOptionsViewController: UIViewController {

    
    //Labels
    @IBOutlet var useEmojisLabel: UILabel!
    @IBOutlet var convertAsciiToEmojiLabel: UILabel!
    @IBOutlet var autoLoadImagesLabel: UILabel!
    @IBOutlet var saveMobileBandWidthLabel: UILabel!
    
    
    //Switches
    @IBOutlet var useEmojisSwitch: UISwitch!
    @IBOutlet var convertAsciiToEmojiSwitch: UISwitch!
    @IBOutlet var autoLoadImagesSwitch: UISwitch!
    @IBOutlet var saveMobileBandwidthSwitch: UISwitch!
    
    
    
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
    
    
    //MARK: Messages Options Actions
    
    @IBAction func useEmojisAction(sender: AnyObject) {
    
        if useEmojisSwitch.on {
            
            print("Use emojis is ON")
            
        } else {
            
            print("Use emojis is OFF")
            
        }
        
        
    }

    
    @IBAction func convertAsciiToEmojiAction(sender: AnyObject) {
        
        if convertAsciiToEmojiSwitch.on {
            
            print("Convert Ascii to Emoji is ON")
            
        } else {
            
            print("Convert Ascii to Emoji is OFF")
            
        }
        
    }
    
    @IBAction func autoLoadImagesAction(sender: AnyObject) {
        
        if autoLoadImagesSwitch.on {
            
            print("Auto Load Images is ON")
            
        } else {
            
            print("Auto Load Images is OFF")
            
        }

        
    }
    
    @IBAction func saveMobileBandwidthAction(sender: AnyObject) {
        
        if saveMobileBandwidthSwitch.on {
            
            print("Save Mobile Bandwidth is ON")
            
        } else {
            
            print("Save Mobile Bandwidth is OFF")
            
        }

        
    }
    
}
