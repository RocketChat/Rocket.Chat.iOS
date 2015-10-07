
//
//  MyAccountBarTabViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/14/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class MyAccountBarTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Hide the bottom bar
        tabBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //Function to get the AccountBarViewController's index
    func findIndexOfAccountBar() -> Int {
        
        if viewControllers == nil {
            return -1
        }
        for (index, value) in (viewControllers?.enumerate())! {
            if value is AccountBarViewController {
                return index
            }
        }
        return -1
    }
    
    //Function to get the MyAccountBarViewController's index
    func findIndexOfMyAccountBar() -> Int {
        
        if viewControllers == nil {
            return -1
        }
        for (index, value) in (viewControllers?.enumerate())! {
            if value is MyAccountBarViewController {
                return index
            }
        }
        return -1
    }
}
