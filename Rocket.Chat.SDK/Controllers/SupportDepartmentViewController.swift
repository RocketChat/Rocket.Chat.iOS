//
//  SupportDepartmentViewController.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

public protocol SupportDepartmentViewControllerDelegate: class {
    func didSelect(department: Department)
}

class SupportDepartmentViewController: UITableViewController, LivechatManagerInjected {

    weak var delegate: SupportDepartmentViewControllerDelegate?

    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .middle)
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .checkmark
    }

    @IBAction func didTouchCancelButton(_ sender: UIBarButtonItem) {
        dismissSelf()
    }

    @IBAction func didTouchDoneButton(_ sender: UIBarButtonItem) {
        delegate?.didSelect(department: livechatManager.departments[selectedIndexPath.row])
        dismissSelf()
    }

    func dismissSelf() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return livechatManager.departments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartmentCell", for: indexPath)

        cell.accessoryType = .none
        if let label = cell.contentView.viewWithTag(1) as? UILabel {
            label.text = livechatManager.departments[indexPath.row].name
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = livechatManager.departments[indexPath.row].description
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}
