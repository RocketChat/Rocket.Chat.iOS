//
//  MessagesViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController
import RealmSwift
import DifferenceKit

final class MessagesViewController: RocketChatViewController {

    let viewModel = MessagesViewModel(controllerContext: nil)
    let viewSubscriptionModel = MessagesSubscriptionViewModel()
    let viewSizingModel = MessagesSizingManager()

    var subscription: Subscription! {
        didSet {
            viewModel.subscription = subscription
            viewSubscriptionModel.subscription = subscription
        }
    }

    var sectionsToAddLater: [AnyChatSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(BasicMessageCell.nib, forCellWithReuseIdentifier: BasicMessageCell.identifier)
        collectionView.register(DateSeparatorCell.nib, forCellWithReuseIdentifier: DateSeparatorCell.identifier)

        viewModel.controllerContext = self
        viewModel.onDataChanged = {
            self.data = self.viewModel.data
            self.updateData()
        }

        viewSubscriptionModel.onDataChanged = {
            // TODO: handle updates on the Subscription object, such like title view
        }
    }

    func openURL(url: URL) {
        WebBrowserManager.open(url: url)
    }

}

extension MessagesViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.numberOfSections - indexPath.section < 5 {
            viewModel.fetchMessages(from: viewModel.oldestMessageDateBeingPresented)
        }

        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = viewModel.itemAt(indexPath) else {
            return .zero
        }

        let sectionViewModel = section.viewModels()[indexPath.row]
        if let size = viewSizingModel.size(for: sectionViewModel.differenceIdentifier) {
            return size
        } else {
            let sizingCell = BasicMessageCell.sizingCell
            sizingCell.prepareForReuse()
            sizingCell.viewModel = sectionViewModel
            sizingCell.configure()
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()

            let size = sizingCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            viewSizingModel.set(size: size, for: sectionViewModel.differenceIdentifier)

            return size
        }
    }

}

extension MessagesViewController: ChatDataUpdateDelegate {

    func didUpdateChatData(newData: [AnyChatSection]) {
        viewModel.data = newData
    }

}

extension MessagesViewController: UserActionSheetPresenter {

    func presentActionSheetForUser(_ user: User, source: (view: UIView?, rect: CGRect?)?) {
        presentActionSheetForUser(user, subscription: subscription, source: source)
    }

}
