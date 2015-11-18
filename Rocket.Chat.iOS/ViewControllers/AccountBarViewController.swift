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
        
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        meteor = ad.meteorClient
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userChange:", name: "users_changed", object: nil)
        
        let userNameAndStatus = self.getUsernameAndStatus()
        
        self.usernameLabel.text = userNameAndStatus.0
        
        self.changeStatusIcon(userNameAndStatus.1)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "users_changed", object: nil)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getUsernameAndStatus()-> (String, String) {
        
        let users = self.meteor.collections["users"]! as! M13MutableOrderedDictionary
        
        let userName = users[self.meteor.userId]["username"] as? String
        
        let userStatus = users[self.meteor.userId]["status"] as? String ?? "offline"

        return (userName!, userStatus)
    }
    
    
    func changeStatusIcon(currentStatus: String) {
        
        switch currentStatus {
            
            case "online":
                self.statusIcon.image = UIImage(named: "Green")
                
            case "away":
                self.statusIcon.image = UIImage(named: "Yellow")
                
            case "busy":
                self.statusIcon.image = UIImage(named: "Red")
                
            case "offline":
                self.statusIcon.image = UIImage(named: "Grey")
                
            default:
                self.statusIcon.image = UIImage(named: "Green")
        }
        
    }
    
    
    func userChange(notification:NSNotification){
        
        if notification.userInfo!["_id"] as? String == self.meteor.userId {
            
            let status = notification.userInfo!["status"] as? String ?? "offline"
            
            self.changeStatusIcon(status)
            
        }
        
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

