//
//  AccountBar.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class AccountBarViewController: UIViewController {
  
  // MARK: Properties
  @IBOutlet weak var detailsButton: UIButton!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var avatarIcon: UIImageView!
  @IBOutlet weak var statusIcon: UIImageView!
    
    
  /** this will tell you what the state was before the touch event */
  var accountOptionsWereOpen = false
  
  var delegate:SwitchAccountViewDelegate! = nil
    
  var meteor:MeteorClient!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Get the username and
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    meteor = ad.meteorClient
    let users = meteor.collections["users"] as! M13MutableOrderedDictionary
    
    let obj = users.objectAtIndex(0)
    print(obj["_id"])
    
    self.usernameLabel.text = obj["username"] as? String
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  // MARK: - Navigation
  
  //MARK: Navigation
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
      //rotate icon 180
      let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
      rotateAnimation.fromValue = 0.0
      rotateAnimation.toValue = CGFloat(M_PI * 1.0)
      rotateAnimation.duration = 0.2
      
      //handle the callback in the animationDidStop below
      rotateAnimation.delegate = self
      detailsButton.layer.addAnimation(rotateAnimation, forKey: nil)
    
  }
  
  
  override func animationDidStop(anim: CAAnimation, finished flag: Bool){
    
    if (detailsButton.imageView?.image == UIImage(named: "Arrow-Up")) {
      detailsButton.imageView?.image = UIImage(named: "Arrow-Down")
    } else {
      detailsButton.imageView?.image = UIImage(named: "Arrow-Up")
    }
    if ((delegate) != nil){ // let delegate know about event
	    delegate!.didClickOnAccountBar(accountOptionsWereOpen)
  	  accountOptionsWereOpen = !accountOptionsWereOpen
    }
  }
  
}


/** This protocol is used for handling events from the AccountBar. */
protocol SwitchAccountViewDelegate {
  func didClickOnAccountBar(accountOptionsWereOpen: Bool)
}

