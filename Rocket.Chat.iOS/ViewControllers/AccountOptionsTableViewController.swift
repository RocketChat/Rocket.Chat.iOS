//
//  AccountOptionsTableViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/30/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController
import ObjectiveDDP

class AccountOptionsTableViewController: UITableViewController {
    
    var meteor = MeteorClient!()
    var ad:AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ad = UIApplication.sharedApplication().delegate as? AppDelegate
        self.meteor = self.ad!.meteorClient

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
    
        //User's Status
        if (indexPath.section == 0){
            //Get the username and
            
            switch indexPath.row {
                
            case 0:
                print("online")
                self.meteor.callMethodName("UserPresence:setDefaultStatus", parameters: ["online"], responseCallback: { (response, error) -> Void in
                    
                    if error != nil{
                        print("Error: \(error.description)")
                        return
                    }
                    
//                    print(response["result"])
                    self.chooseOptionAndSetViews("ChatNav",color: "Green")
                    NSUserDefaults.standardUserDefaults().setValue("online", forKey: "previousStatus")

                })
            case 1:
                print("Away")
                self.meteor.callMethodName("UserPresence:setDefaultStatus", parameters: ["away"], responseCallback: { (response, error) -> Void in
                    
                    if error != nil{
                        print("Error: \(error.description)")
                        return
                    }
                    
//                    print(response["result"])
                    self.chooseOptionAndSetViews("ChatNav",color: "Yellow")
                    NSUserDefaults.standardUserDefaults().setValue("away", forKey: "previousStatus")

                })
            case 2:
                print("Busy")
                self.meteor.callMethodName("UserPresence:setDefaultStatus", parameters: ["busy"], responseCallback: { (response, error) -> Void in
                    
                    if error != nil{
                        print("Error: \(error.description)")
                        return
                    }
                    
//                    print(response["result"])
                    self.chooseOptionAndSetViews("ChatNav",color: "Red")
                    NSUserDefaults.standardUserDefaults().setValue("busy", forKey: "previousStatus")
                })
            case 3:
                print("Invisible")
                
                self.meteor.callMethodName("UserPresence:setDefaultStatus", parameters: ["offline"], responseCallback: { (response, error) -> Void in
                    
                    if error != nil{
                        print("Error: \(error.description)")
                        return
                    }
                    
//                    print(response["result"])
                    self.chooseOptionAndSetViews("ChatNav",color:"Grey")
                    NSUserDefaults.standardUserDefaults().setValue("offline", forKey: "previousStatus")

                })
            default:
                print("default")
            }
            
        }
        //If user selects MySettings
        else if (indexPath.section == 1 && indexPath.row == 0) {
         
            self.chooseOptionAndSetViews("Settings", color: nil)

        }
    
        else if (indexPath.section == 1 && indexPath.row == 1) {
    
            let ad = UIApplication.sharedApplication().delegate as! AppDelegate
            let meteor = ad.meteorClient
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateInitialViewController()
    
            if (meteor.connected){
                
                meteor.logout()
                print("Logged out")
                ad.window?.rootViewController = loginVC
            
            } else {
            
                let alert = UIAlertController(title: "Error", message: "Connection is lost", preferredStyle: UIAlertControllerStyle.Alert)
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            
            }
            
        }
    

    }
    
    
    /* 
    This func is to handle left menu's view when user chooses an option.
    Also when user chooses a status the statusIcon changes color and
    the arrow turns down
    */
    func chooseOptionAndSetViews(viewToAppear:String,color:String?) {
        
        //Get the AccountBar's tab controller
        let MyAccountTabBarController = tabBarController?.parentViewController?.childViewControllers[0] as! MyAccountBarTabViewController
        
        /******** Prepare the account bar for when we exit settings ********/
         
         //Get the accountBarView
        let accountBarView = MyAccountTabBarController.viewControllers![MyAccountTabBarController.findIndexOfAccountBar()] as! AccountBarViewController
        
        //Set accountOptionWereOpen to false so when we get back from settings the account bar will work right
        accountBarView.accountOptionsWereOpen = false
        
        //Rotate the arrow down
        accountBarView.detailsButton?.imageView?.image = UIImage(named: "Arrow-Down")
        
        if color != nil {
            accountBarView.statusIcon.image = UIImage(named: color!)
        }
        /************/
         
         //get LeftMenu's tab bar controller
        let leftMenuTabBarController = tabBarController as! LeftMenuTabBarViewController
        
        
        switch viewToAppear{
            
            case "ChatNav":
                //Set the left menu's view
                tabBarController?.selectedViewController = tabBarController?.viewControllers![leftMenuTabBarController.findIndexOfChatNav()]
                
            case "Settings":
                //Create MySettingsViewController instance
                let mySettingsVC = storyboard?.instantiateViewControllerWithIdentifier("mySettings") as! MySettingsViewController
                
                //Set it as rootViewController in the navigation controller
                let centerNewNav = UINavigationController(rootViewController: mySettingsVC)
                
                
                //Set the settings controller as the center view controller in the MMDrawer
                self.ad!.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
                
                //Close the drawer
                self.ad!.centerContainer?.closeDrawerAnimated(true, completion: nil)
                tabBarController?.selectedViewController = tabBarController?.viewControllers![leftMenuTabBarController.findIndexOfMySettings()]
            
            default:
                tabBarController?.selectedViewController = tabBarController?.viewControllers![leftMenuTabBarController.findIndexOfMySettings()]
        
        }
        
    }
}