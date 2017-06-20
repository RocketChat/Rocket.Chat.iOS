//
//  ViewController.swift
//  SDKExample
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket Chat. All rights reserved.
//

import UIKit
import RocketChat

class ViewController: UIViewController {

    @IBOutlet weak var serverAddrTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var securedSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTouchUpInsideLoginButton(_ sender: UIButton) {
        guard let serverAddr = serverAddrTextField.text,
            let email = emailTextField.text,
            let name = nameTextField.text,
            let message = messageTextField.text
            else {
            return
        }
        let secured = securedSwitch.isOn

        RocketChat.configure(withServerURL: URL(string: serverAddr)!, secured: secured) {
            let livechatManager = RocketChat.injectionContainer.livechatManager
            livechatManager.initiate {
                livechatManager.registerGuestAndLogin(withEmail: email, name: name, toDepartment: livechatManager.departments.first!, message: message) {
                    DispatchQueue.main.async {
                        guard let controller = livechatManager.getLiveChatViewController() else {
                            return
                        }
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}

