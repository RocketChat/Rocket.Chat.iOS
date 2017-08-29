//
//  SupportViewController.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

public class SupportViewController: UITableViewController, LivechatManagerInjected {

    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var initialMessageView: UITextView!

    var allowChangeDepartment = true {
        didSet {
        }
    }
    var department: Department? {
        didSet {
            // department may be set before view initialized
            departmentLabel?.text = department?.name
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        department = livechatManager.departments.first
        departmentLabel.text = department?.name
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "ShowDepartments":
            guard let viewController = segue.destination as? SupportDepartmentViewController else {
                return
            }
            viewController.delegate = self
            let index = livechatManager.departments.index(where: { (department) -> Bool in
                guard let selfDepartment = self.department else { return false }
                return department == selfDepartment
            }) ?? 0
            viewController.selectedIndexPath = IndexPath(row: index, section: 0)
        default:
            break
        }
    }

    // MARK: - Actions
    @IBAction func didTouchSendButton(_ sender: UIBarButtonItem) {
        prepareChatViewController()
    }

    @IBAction func didTouchCancelButton(_ sender: UIBarButtonItem) {
        dismissSelf()
    }

    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    func prepareChatViewController() {
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
        guard let message = initialMessageView.text else {
            let alert = UIAlertController(title: "Initial message is required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        LoaderView.showLoader(for: self.view, preset: .white)
        livechatManager.registerGuestAndLogin(withEmail: email, name: name, toDepartment: department, message: message) {
            LoaderView.hideLoader(for: self.view)
            guard let viewController = self.livechatManager.getLiveChatViewController() else { return }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension SupportViewController: SupportDepartmentViewControllerDelegate {
    public func didSelect(department: Department) {
        self.department = department
    }
}

extension SupportViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            prepareChatViewController()
        }
        return false
    }
}
