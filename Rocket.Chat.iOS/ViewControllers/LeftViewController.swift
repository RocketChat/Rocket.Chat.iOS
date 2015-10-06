//
//  LeftViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController, SwitchAccountViewDelegate {

  @IBOutlet weak var accountTopView: UIView!
  @IBOutlet weak var leftMainContainer: UIView!
  
    var accountTabBarContainer : MyAccountBarTabViewController?
    var tabBarContainer : LeftMenuTabBarViewController?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.rocketBlueColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  override func prefersStatusBarHidden() -> Bool {
    switch UIDevice.currentDevice().orientation{
    case .Portrait, .PortraitUpsideDown:
			return false
    case .LandscapeLeft, .LandscapeRight:
    	return true
    default:
      return false
    }

  }
  

  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    //set self as the delegate in the account bar that will handle the event coming up from there.
    if segue.identifier == "embedAccountBar"{
      accountTabBarContainer = segue.destinationViewController as? MyAccountBarTabViewController
        let accountBarTabView = accountTabBarContainer?.viewControllers![0] as! AccountBarViewController
        accountBarTabView.delegate = self
    } else if segue.identifier == "embedChatNav"{
      tabBarContainer = segue.destinationViewController as? LeftMenuTabBarViewController
    }
  }
  
  // MARK: SwitchAccountViewDelegate
  func didClickOnAccountBar(accountOptionsWereOpen: Bool){
		// not much to do here, simply let the tab bar container know about the event, so it can swap the selected view.
    if (tabBarContainer != nil){
      tabBarContainer?.didClickOnAccountBar(accountOptionsWereOpen)
    }
  }

}
