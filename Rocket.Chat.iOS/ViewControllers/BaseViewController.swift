//
//  BaseViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 9/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class BaseViewController: UIViewController {

  var meteor: MeteorClient!
  
//  init(client: MeteorClient) {
//    self.meteor = client
//    super.init(nibName: nil, bundle: nil)
//    print("loading from custom init")
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//
//    print("loading from SB")
//    super.init(nibName: nil, bundle: nil)
//    loadCustomData()
//    
//
//  }
  
  override func viewWillAppear(animated: Bool) {
    loadCustomData()
  }

  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  // MARK: - Helpers

  func loadCustomData(){
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    meteor = ad.meteorClient
  }
}
