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
            tableView.delegate = self

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
            frame: CGRect(x: 20, y: 0, width: tableView.bounds.width - 16, height: cellModel.nameHeight)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(nameDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        return textField
    }()

    lazy var descriptionTextView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView(
            frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 16, height: cellModel.descriptionHeight)
        )
        textView.font = nameTextField.font
        NotificationCenter.default.addObserver(self, selector: #selector(descriptionDidChange(_:)), name: UITextView.textDidChangeNotification, object: textView)
        return textView
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
            descriptionTextView.text = cellModel.descriptionText
            descriptionTextView.placeholder = cellModel.descriptionPlaceholder
        }
    }

    @objc func nameDidChange(_ textField: UITextField) {
        cellModel.file.name = nameTextField.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }

    @objc func descriptionDidChange(_ textField: UITextField) {
        cellModel.file.description = descriptionTextView.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        nameTextField.frame = CGRect(x: 20, y: 0, width: tableView.bounds.width - 16, height: cellModel.nameHeight)
        descriptionTextView.frame = CGRect(x: 16, y: 0, width: tableView.bounds.width - 16, height: cellModel.descriptionHeight)
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
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: cellModel.heightForRow(at: indexPath))
        )

        switch indexPath.row {
        case 0:
            cell.addSubview(nameTextField)
        case 1:
            cell.addSubview(descriptionTextView)
        default:
            break
        }

        return cell
    }
}

extension SEComposeFileCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellModel.heightForRow(at: indexPath)
    }
}
