//
//  SignupCustomFieldsTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 14/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SignupCustomFieldsTableViewController: BaseTableViewController {

    lazy var customFields: [CustomFieldTableViewCell] = {
        return AuthSettingsManager.settings?.customFields.compactMap { customField in
            guard let customFieldCell = CustomFieldTableViewCell.instantiateFromNib() else {
                return nil
            }

            customFieldCell.customField = customField
            return customFieldCell
        } ?? []
    }()

}

extension SignupCustomFieldsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customFields.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return customFields[indexPath.row]
    }

}
