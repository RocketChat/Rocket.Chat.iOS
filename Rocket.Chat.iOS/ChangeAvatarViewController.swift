

//
//  ChangeAvatarViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/20/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class ChangeAvatarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set the navigation's title to rocketMainFontColor
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.rocketMainFontColor()]

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
