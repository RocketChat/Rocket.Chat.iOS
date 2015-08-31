//
//  AccountBar.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class AccountBar: UIViewController {

  // MARK: Properties
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var statusIcon: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var detailsButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    detailsButton.setTitle(">", forState: UIControlState.Normal)
    detailsButton.transform = CGAffineTransformMakeRotation( CGFloat(90*M_PI/180));


  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  //MARK: Navigation
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("account bar tapped!")
    //TODO: Insert code here that brings up account status and settings
  }

  
  
}
