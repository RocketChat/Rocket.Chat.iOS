//
//  MyAccountBarViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/14/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class MyAccountBarViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
                
        //Get the LeftMenuTabBarViewController
        let leftMenuTabBarController = tabBarController?.parentViewController?.childViewControllers[1] as! LeftMenuTabBarViewController
        
        //Set the left menu view to chatnav
        leftMenuTabBarController.selectedViewController = leftMenuTabBarController.viewControllers![leftMenuTabBarController.findIndexOfChatNav()]
        
        //Set the account bar to accountBarView
        tabBarController?.selectedViewController = tabBarController?.viewControllers![0]
        
    }

}
