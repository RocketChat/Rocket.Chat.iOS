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
        searchResult = [:]

        if prefix == "@" && word.characters.count > 0 {
            guard let users = try? Realm().objects(User.self).filter(NSPredicate(format: "username BEGINSWITH[c] %@", word)) else { return }

            for user in users {
                if let username = user.username {
                    searchResult[username] = user
                }
            }

            if "here".contains(word) {
                searchResult["here"] = UIImage(named: "Hashtag")
            }

            if "all".contains(word) {
                searchResult["all"] = UIImage(named: "Hashtag")
            }

        } else if prefix == "#" && word.characters.count > 0 {
            guard let channels = try? Realm().objects(Subscription.self).filter("auth != nil && (privateType == 'c' || privateType == 'p') && name BEGINSWITH[c] %@", word) else { return }

            for channel in channels {
                searchResult[channel.name] = channel.type == .channel ? UIImage(named: "Hashtag") : UIImage(named: "Lock")
            }

        }

        let show = (searchResult.count > 0)
        showAutoCompletionView(show)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return AutocompleteCell.minimumHeight * CGFloat(searchResult.count)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return autoCompletionCellForRowAtIndexPath(indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AutocompleteCell.minimumHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(searchResult.keys)[indexPath.row]
        acceptAutoCompletion(with: "\(key) ", keepPrefix: true)
    }

    private func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> AutocompleteCell {
        guard let cell = autoCompletionView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier) as? AutocompleteCell else {
            return AutocompleteCell(style: .`default`, reuseIdentifier: AutocompleteCell.identifier)
        }
        cell.injectionContainer = injectionContainer
        cell.selectionStyle = .default

        let key = Array(searchResult.keys)[indexPath.row]
        if let user = searchResult[key] as? User {
            cell.avatarView.isHidden = false
            cell.imageViewIcon.isHidden = true
            cell.avatarView.user = user
        } else {
            cell.avatarView.isHidden = true
            cell.imageViewIcon.isHidden = false

            if let image = searchResult[key] as? UIImage {
                cell.imageViewIcon.image = image.imageWithTint(.lightGray)
            }
        }

        cell.labelTitle.text = key
        return cell
    }
}
