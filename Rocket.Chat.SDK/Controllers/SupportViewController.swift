//
//  SupportViewController.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

public class SupportViewController: UIViewController, LiveChatManagerInjected {

    @IBOutlet weak var departmentPickerView: UIPickerView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var initialMessageField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    public var injectionContainer: InjectionContainer!

    var allowChangeDepartment = true {
        didSet {
            if allowChangeDepartment {
                departmentPickerView.isHidden = false
            } else {
                departmentPickerView.isHidden = true
            }
        }
    }
    var department: Department?

    override public func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem = leftBarButton
    }

    // MARK: - Action

    @IBAction func didTouchOutside(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func didTouchStartButton(_ sender: UIButton) {
        presentChatViewController()
    }

    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    func presentChatViewController() {
        // TODO: prepare and wait for SDK configuration to finish
        guard let email = emailField.text else {
            let alert = UIAlertController(title: "Email is required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let name = nameField.text else {
            let alert = UIAlertController(title: "Name is required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if department == nil {
            department = livechatManager.departments.first
        }
        guard let department = department else {
            let alert = UIAlertController(title: "No department available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let message = initialMessageField.text else {
            let alert = UIAlertController(title: "Initial message is required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        activityIndicator.startAnimating()
        livechatManager.registerGuestAndLogin(withEmail: email, name: name, toDepartment: department, message: message) {
            self.activityIndicator.stopAnimating()
            guard let viewController = self.livechatManager.getLiveChatViewController() else { return }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension SupportViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            presentChatViewController()
        }
        return false
    }
}

extension SupportViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < livechatManager.departments.count else { return nil }
        return livechatManager.departments[row].name
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < livechatManager.departments.count else { return }
        self.department = livechatManager.departments[row]
    }
}

extension SupportViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return livechatManager.departments.count
    }
}
