//
//  EditAccountViewController.swift
//  Rocket.Chat
//
//  Created by Dennis Post on 14.02.18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Eureka
import GenericPasswordRow
import ViewRow

public class EditAccountViewController: FormViewController {

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

        form = Section()
        // MARK: Edit Profile
            <<< TextRow("username") {
                $0.title = "Username"
                $0.add(rule: RuleRequired())
                $0.value = user.username
                $0.validationOptions = .validatesOnChangeAfterBlurred
                // Validation on leave
            }

            <<< ButtonRow("save_account") {
                $0.title = "Save Account"
            }
        
        +++ Section()

    }

}
