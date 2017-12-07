//
//  ChatControllerAutocomplete.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension ChatViewController {
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        guard let realm = Realm.shared else { return }

        searchResult = []

        if prefix == "@" {
            searchResult = User.search(usernameContaining: word, preference: dataController.messagesUsernames)

            if "here".contains(word) || word.count == 0 {
                searchResult.append(("here", UIImage(named: "Hashtag") as Any))
            }

            if "all".contains(word) || word.count == 0 {
                searchResult.append(("all", UIImage(named: "Hashtag") as Any))
            }
        } else if prefix == "#" && word.count > 0 {
            let channels = realm.objects(Subscription.self).filter("auth != nil && (privateType == 'c' || privateType == 'p') && name BEGINSWITH[c] %@", word)

            for channel in channels {
                searchResult.append((channel.name, (channel.type == .channel ? UIImage(named: "Hashtag") : UIImage(named: "Lock")) as Any))
            }

        } else if prefix == "/" {
            let commands: Results<Command>
            if word.count > 0 {
                commands = realm.objects(Command.self).filter("command BEGINSWITH[c] %@", word)
            } else {
                commands = realm.objects(Command.self)
            }

            commands.forEach {
                searchResult.append(($0.command, $0))
            }
        }

        let show = (searchResult.count > 0)
        showAutoCompletionView(show)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return AutocompleteCell.minimumHeight * CGFloat(searchResult.count)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return autoCompletionCellForRowAtIndexPath(indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AutocompleteCell.minimumHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = searchResult[indexPath.row].0
        acceptAutoCompletion(with: "\(key) ", keepPrefix: true)
    }

    private func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> AutocompleteCell {
        guard let cell = autoCompletionView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier) as? AutocompleteCell else {
            return AutocompleteCell(style: .`default`, reuseIdentifier: AutocompleteCell.identifier)
        }
        cell.selectionStyle = .default

        if let user = searchResult[indexPath.row].1 as? User {
            cell.avatarView.isHidden = false
            cell.imageViewIcon.isHidden = true
            cell.avatarView.user = user
        } else {
            cell.avatarView.isHidden = true
            cell.imageViewIcon.isHidden = false

            if let image = searchResult[indexPath.row].1 as? UIImage {
                cell.imageViewIcon.image = image.imageWithTint(.lightGray)
            }
        }

        cell.labelTitle.text = searchResult[indexPath.row].0
        return cell
    }
}
