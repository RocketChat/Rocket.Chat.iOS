//
//  EditProfileViewController.swift
//  Rocket.Chat
//
//  Created by Dennis Post on 22.11.17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Eureka
import GenericPasswordRow
import ViewRow

public class EditProfileViewController: FormViewController {
    
    var user: User?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let meRequest = UserMeRequest()
        API.shared.fetch(meRequest, { result in
            print(result?.mee)
            self.user = result?.user
            DispatchQueue.main.async {
                self.buildForm()
            }
//            performSelector(onMainThread: self.buildForm, with: nil, waitUntilDone: true)
            
        })

    }
    func buildForm() {
        guard let user = user else { return }
        
        form +++ Section()
            // MARK: Edit Profile
            <<< ViewRow<UIView>()
                .cellSetup { (cell, _) in
                    
                    cell.view = UIView()
                    cell.height = { return CGFloat(160) }
                    guard let avatarContainerView = cell.view else { return }
                    avatarContainerView.frame.size = CGSize(width: 320, height: 160)
                    
                    if let avatarView = AvatarView.instantiateFromNib() {
                        avatarView.frame = CGRect(
                            x: (320 / 2) - 75,
                            y: 5,
                            width: 150,
                            height: 150
                        )
                        avatarView.user = user
                        avatarView.layer.cornerRadius = 15
                        avatarView.layer.masksToBounds = true
                        avatarContainerView.addSubview(avatarView)
                    }
                    cell.contentView.addSubview(avatarContainerView)
                }
            
            <<< TextRow("name") {
                $0.title = "Name"
                $0.add(rule: RuleRequired())
                $0.value = user.displayName()
                $0.validationOptions = .validatesOnChangeAfterBlurred
                // Validation on leave
            }

            <<< TextRow("username") {
                $0.title = "Username"
                $0.add(rule: RuleRequired())
                $0.value = user.username
                $0.validationOptions = .validatesOnChangeAfterBlurred
                // Validation on leave
            }
        
            <<< TextRow("email") {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.value = user.emails.first?.email
                $0.validationOptions = .validatesOnChangeAfterBlurred
                // Validation on leave
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = validationMsg
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            <<< ButtonRow("save_profile") {
                $0.title = "Save Profile"
                $0.onCellSelection(self.saveProfile)
            }
            
            // MARK: Edit Password
            +++ Section("Password")
            
            <<< GenericPasswordRow("password") {
                $0.placeholder = "Create a password"
                // Validation with confirmation field
            }
            
            <<< GenericPasswordRow("password_confirmation") {
                $0.placeholder = "Create a password"
                // Validation with confirmation field
            }
            
            <<< ButtonRow("save_password") {
                $0.title = "Save Password"
            }
    }
    
    func saveProfile(cell: ButtonCellOf<String>, row: ButtonRow) {
        let validationErrors = form.validate()
        if validationErrors.isEmpty {
            let updatedUser = User()
            updatedUser.name = (form.rowBy(tag: "name") as! TextRow).value
            updatedUser.username = (form.rowBy(tag: "username") as! TextRow).value
            let newEmail = Email()
            newEmail.email = (form.rowBy(tag: "email") as! TextRow).value!
            updatedUser.emails.append(newEmail)
        
            let selectedIndex = DatabaseManager.selectedIndex
            guard let servers = DatabaseManager.servers, let userId = servers[selectedIndex][ServerPersistKeys.userId] else { return }
            let updateRequest = UserUpdateRequest(userId: userId, user: updatedUser)
            API.shared.fetch(updateRequest, { result in
                print("done")
                guard let success = result?.success else { return }
                if success {
                    print(result?.user)
                } else {
                    DispatchQueue.main.async {
                        let saveErrorView = UIAlertController(title: "Save Error", message: "Profile could not be saved.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Okay", style: .default)
                        saveErrorView.addAction(defaultAction)
                        self.present(saveErrorView, animated: true)
                    }
                }
                
            })
        } else {
            let validationErrorView = UIAlertController(title: "Validation Error", message: validationErrors.first?.msg, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay", style: .default)
            validationErrorView.addAction(defaultAction)
            present(validationErrorView, animated: true)
        }
    }
}
