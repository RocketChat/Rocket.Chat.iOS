//
//  MySettingsViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/12/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class MySettingsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var messagesOptionsLabel: UILabel!
    @IBOutlet var soundOptionsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the navigation's title to rocketMainFontColor
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.rocketMainFontColor()]

        //Set the messages title to rocketMainFontColor
        messagesOptionsLabel.textColor = UIColor.rocketMainFontColor()
        soundOptionsLabel.textColor = UIColor.rocketMainFontColor()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    //Menu button action
    @IBAction func backButton(sender: AnyObject) {
        
        //get the appDelegate
        let appdelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Open the left drawer
        appdelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
     
    }
    
}
