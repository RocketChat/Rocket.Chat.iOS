//
//  SupportFormViewController.swift
//  SDKExample
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket Chat. All rights reserved.
//

import UIKit
import RocketChat

class SupportFormViewController: UIViewController {

    @IBOutlet weak var serverAddrTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var securedSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTouchOutside(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    func presentLivechat() {
        guard let serverAddr = serverAddrTextField.text,
            let email = emailTextField.text,
            let name = nameTextField.text,
            let message = messageTextField.text
            else {
            return
        }
        let secured = securedSwitch.isOn
        activityIndicator.startAnimating()

        RocketChat.configure(withServerURL: URL(string: serverAddr)!, secured: secured) {
            let livechatManager = RocketChat.injectionContainer.livechatManager
            livechatManager.initiate {
                guard let department = livechatManager.departments.first else {
                    let alert = UIAlertController(title: "No department available", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                livechatManager.registerGuestAndLogin(withEmail: email, name: name, toDepartment: department, message: message) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        guard let controller = livechatManager.getLiveChatViewController() else {
                            return
                        }
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
}

extension SupportFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            presentLivechat()
        }
        return false
    }
}

