//
//  MentionsTextFieldTableViewCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 07.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import TagListView

class MentionsTextFieldTableViewCell: UITableViewCell, FormTableViewCellProtocol, TagListViewDelegate {
    static let identifier = "kMentionsTextFieldTableViewCell"
    static let xibFileName = "MentionsTextFieldTableViewCell"
    static let defaultHeight: Float = -1
    weak var delegate: FormTableViewDelegate?
    var key: String?

    @IBOutlet private weak var tagListView: TagListView!
    @IBOutlet weak var imgLeftIcon: UIImageView!
    @IBOutlet weak var textFieldInput: UITextField!

    private var users: [String: TagView] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()

        textFieldInput.clearButtonMode = .whileEditing
        textFieldInput.delegate = self
        tagListView.textFont = UIFont.systemFont(ofSize: 16)
        tagListView.delegate = self
    }

    func height() -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func setPreviousValue(previous: Any) {
        if let previous = previous as? String {
            textFieldInput.text = previous
        }
    }

    @IBAction func textFieldInputEditingChanged(_ sender: Any) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.fetchUsers), object: nil)
        self.perform(#selector(self.fetchUsers), with: nil, afterDelay: 1)
    }

    @objc private func fetchUsers() {
        delegate?.updateDictValue(key: key ?? "", value: textFieldInput.text ?? "")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        users.removeAll()
        tagListView.removeAllTags()
    }

    // MARK: Tag
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        for tag in users where tag.value === tagView {
            users.removeValue(forKey: tag.key)
        }

        tagListView.removeTagView(tagView)
        delegate?.updateTable(key: key ?? "")
    }

}

extension MentionsTextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = textFieldInput.text, name.count > 0 else {
            return true
        }

        textFieldInput.text = nil

        if users[name] == nil {
            users[name] = tagListView.addTag(name)
            delegate?.updateTable(key: key ?? "")
        }

        return false
    }

}
