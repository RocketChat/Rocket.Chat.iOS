//
//  MainViewController.swift
//  SDKExample
//
//  Created by Lucas Woo on 6/29/17.
//  Copyright © 2017 Rocket Chat. All rights reserved.
//

import UIKit
import RocketChat

class MainViewController: UIViewController {

    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var secureSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func didTouchSupportButton(_ sender: Any) {
        presentSupportViewController()
    }

    func presentSupportViewController() {
        guard let serverAddr = serverAddressField.text else { return }
        guard let serverUrl = URL(string: serverAddr) else {
            let alert = UIAlertController(title: "Validation Error", message: "Server Address is not a valid URL", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return
        }
        let secured = secureSwitch.isOn
        activityIndicator.startAnimating()
        RocketChat.configure(withServerURL: serverUrl, secured: secured) {
            RocketChat.livechat().initiate {
                _ = RocketChat.livechat().presentSupportViewController()
            }
        }
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presentSupportViewController()
        return false
    }
}
