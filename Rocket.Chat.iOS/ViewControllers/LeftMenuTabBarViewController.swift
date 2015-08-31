//
//  LeftMenuTabBarViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/30/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class LeftMenuTabBarViewController: UITabBarController, SwitchAccountViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
			// hide the tabbar, as we're only using this container to programmatically switch between the 2 views.
      tabBar.hidden = true
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  
  // MARK: SwitchAccountViewDelegate
  func didClickOnAccountBar(accountOptionsWereOpen: Bool){
   
    if (accountOptionsWereOpen){ //need to show original chatNav menu
      selectedIndex = findIndexOfChatNav()
      selectedViewController = viewControllers![selectedIndex]
      
    } else { // need to show account options
			selectedIndex = findIndexOfAccountOptions()
      selectedViewController = viewControllers![selectedIndex]
    }
    
  }
  
  
  // MARK: Helpers
  
  /** Returns the index of the ChatNav view, or -1 if it can't find it. */
  func findIndexOfChatNav() -> Int {
    if viewControllers == nil {
      return -1
    }
    for (index, value) in (viewControllers?.enumerate())! {
      if value is ChatsNavTableViewController {
        return index
      }
    }
    return -1
  }

  /** Returns the index of the Account Options view, or -1 if it can't find it. */
  func findIndexOfAccountOptions() -> Int {
    if viewControllers == nil {
      return -1
    }
    for (index, value) in (customizableViewControllers?.enumerate())! {
      if value is AccountOptionsTableViewController {
        return index
      }
    }
    return -1
  }
}
