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

    override func awakeFromNib() {
        super.awakeFromNib()

        textFieldInput.clearButtonMode = .whileEditing
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
        delegate?.updateDictValue(key: key ?? "", value: textFieldInput.text ?? "")
    }

    @IBAction func textFieldDidEndEditing(_ sender: Any) {
        guard let name = textFieldInput.text, name.count > 0 else {
            return
        }

        textFieldInput.text = nil
        tagListView.addTag(name)
        delegate?.updateTable()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        tagListView.removeAllTags()
    }

    // MARK: Tag
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag removed: \(title), \(sender)")
    }

}
