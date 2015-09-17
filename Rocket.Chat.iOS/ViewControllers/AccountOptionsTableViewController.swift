//
//  AccountOptionsTableViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/30/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class AccountOptionsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
        // this is to remove the bottom line 'border' on the table view cells
	      tableView.separatorColor = UIColor.clearColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			// the 1st section has 4 rows, the second section has just 2 rows
      return section == 0 ? 4 : 2

    }

	  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
  	  
    	// for some reason, the background color on ipads does not respect the storyboard value.
	    cell.backgroundColor = UIColor(red: 4, green: 67, blue: 106, alpha: 0)
    
  	  //TODO: replace this with hex value once we merge with @kormic's branch
	  }

    
    
    
    //Here is what happens when the user select's an option from account options
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        //If user selects MySettings
        if indexPath.row == 0 {
         
            //get the appDelegate
            let appdelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            //Create MySettingsViewController instance
            let mySettingsVC = storyboard?.instantiateViewControllerWithIdentifier("mySettings")
            
            //Set it as rootViewController in the navigation controller
            let centerNewNav = UINavigationController(rootViewController: mySettingsVC!)
            
            //Set the settings controller as the center view controller in the MMDrawer
            appdelegate.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
            
            //Close the drawer
            appdelegate.centerContainer?.closeDrawerAnimated(true, completion: nil)
            
            //Get the AccountBar's tab controller
            let MyAccountTabBarController = tabBarController?.parentViewController?.childViewControllers[0] as! MyAccountBarTabViewController

            //Set the account bar view
            MyAccountTabBarController.selectedViewController = MyAccountTabBarController.viewControllers![1]
            
            //get LeftMenu's tab bar controller
            let leftMenuTabBarController = tabBarController as! LeftMenuTabBarViewController
            
            //Set the left menu's view
            tabBarController?.selectedViewController = tabBarController?.viewControllers![leftMenuTabBarController.findIndexOfMySettings()]
            
        }
        
    }
    
    
}
