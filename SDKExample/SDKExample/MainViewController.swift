//
//  MainViewController.swift
//  SDKExample
//
//  Created by Lucas Woo on 6/29/17.
//  Copyright © 2017 Rocket Chat. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var supportButton: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        supportButton.layer.cornerRadius = 24
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
