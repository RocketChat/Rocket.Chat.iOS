//
//  SEComposeFileCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import NotificationCenter

class SEComposeFileCell: UICollectionViewCell, SECell {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self

            fileDetailView = SEFileDetailView(
                frame: CGRect(
                    x: 0, y: 0,
                    width: tableView.bounds.width,
                    height: 100.0
                )
            )

            tableView.tableHeaderView = fileDetailView
            tableView.allowsSelection = false
        }
    }

    var fileDetailView: SEFileDetailView?

    lazy var nameTextField: UITextField = {
        let textField = UITextField(
            frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 16, height: 30.0)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(nameDidChange(_:)), name: .UITextFieldTextDidChange, object: textField)
        return textField
    }()

    lazy var descriptionTextField: UITextField = {
        let textField = UITextField(
            frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 16, height: 30.0)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(descriptionDidChange(_:)), name: .UITextFieldTextDidChange, object: textField)
        return textField
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var cellModel = SEComposeFileCellModel.emptyState {
        didSet {
            fileDetailView?.titleLabel.text = cellModel.originalNameText
            fileDetailView?.previewImageView.image = cellModel.image
            fileDetailView?.detailLabel.text = cellModel.detailText
            fileDetailView?.fileSizeLabel.text = cellModel.fileSizeText
            nameTextField.text = cellModel.nameText
            nameTextField.placeholder = cellModel.namePlaceholder
            descriptionTextField.text = cellModel.descriptionText
            descriptionTextField.placeholder = cellModel.descriptionPlaceholder
        }
    }

    @objc func nameDidChange(_ textField: UITextField) {
        cellModel.file.name = nameTextField.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }

    @objc func descriptionDidChange(_ textField: UITextField) {
        cellModel.file.description = descriptionTextField.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let textFieldFrame = CGRect(x: 16, y: 0, width: tableView.bounds.width - 16, height: 30.0)

        nameTextField.frame = textFieldFrame
        descriptionTextField.frame = textFieldFrame
    }
}

extension SEComposeFileCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 16, height: 30.0)
        )

        switch indexPath.row {
        case 0:
            cell.addSubview(nameTextField)
        case 1:
            cell.addSubview(descriptionTextField)
        default:
            break
        }

        return cell
    }
}
