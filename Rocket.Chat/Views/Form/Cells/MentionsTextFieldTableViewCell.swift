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
import SearchTextField

class MentionsTextFieldTableViewCell: UITableViewCell, FormTableViewCellProtocol, TagListViewDelegate {
    static let identifier = "kMentionsTextFieldTableViewCell"
    static let xibFileName = "MentionsTextFieldTableViewCell"
    static let defaultHeight: Float = -1
    weak var delegate: FormTableViewDelegate?
    var key: String?

    @IBOutlet private weak var tagListView: TagListView!
    @IBOutlet weak var imgLeftIcon: UIImageView!
    @IBOutlet weak var textFieldInput: SearchTextField!
    @IBOutlet weak var tagViewTopConstraint: NSLayoutConstraint!

    private var users: [String: TagView] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()

        textFieldInput.clearButtonMode = .whileEditing
        tagListView.textFont = UIFont.systemFont(ofSize: 16)
        tagListView.delegate = self
        tagViewTopConstraint.constant = 0

        textFieldInput.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.addUserToInviteList(name: item.title)
            self.textFieldInput.text = nil
            self.delegate?.updateDictValue(key: self.key ?? "", value: self.invitedUsers())
        }
    }

    private func invitedUsers() -> [String] {
        return users.map { $0.key }
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
        fetchUsers()
    }

    private func fetchUsers() {
        guard
            let realm = Realm.current,
            let name = textFieldInput.text,
            name.count > 0
        else {
            textFieldInput.filterStrings([])
            return
        }

        let users = realm.objects(User.self).filter(
            NSPredicate(format: "name CONTAINS[cd] %@ OR username CONTAINS[cd] %@", name, name)
        )

        let usernames = Array(users).flatMap { $0.username }.filter {
            AuthManager.currentUser()?.username != $0
        }

        textFieldInput.filterStrings(usernames)
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
        updateTagViewConstraint()
        delegate?.updateDictValue(key: key ?? "", value: self.invitedUsers())
        delegate?.updateTable(key: key ?? "")
    }

    private func updateTagViewConstraint() {
        tagViewTopConstraint.constant = tagListView.tagViews.count > 0 ? 12 : 0
    }

    private func addUserToInviteList(name: String) {
        if users[name] == nil {
            users[name] = tagListView.addTag(name)
            updateTagViewConstraint()
            delegate?.updateTable(key: key ?? "")
        }
    }
}
