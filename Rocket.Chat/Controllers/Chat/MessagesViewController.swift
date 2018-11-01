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

protocol SizingCell: class {
    static var sizingCell: UICollectionViewCell & ChatCell { get }
    static func size(for viewModel: AnyChatItem, with horizontalMargins: CGFloat) -> CGSize
}

extension SizingCell {
    static func size(for viewModel: AnyChatItem, with horizontalMargins: CGFloat) -> CGSize {
        var mutableSizingCell = sizingCell
        mutableSizingCell.prepareForReuse()
        mutableSizingCell.adjustedHorizontalInsets = horizontalMargins
        mutableSizingCell.viewModel = viewModel
        mutableSizingCell.configure()
        mutableSizingCell.setNeedsLayout()
        mutableSizingCell.layoutIfNeeded()

        return mutableSizingCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

final class MessagesViewController: RocketChatViewController {

    let viewModel = MessagesViewModel(controllerContext: nil)
    let viewSubscriptionModel = MessagesSubscriptionViewModel()
    let viewSizingModel = MessagesSizingManager()
    let composerViewModel = MessagesComposerViewModel()

    var subscription: Subscription! {
        didSet {
            viewModel.subscription = subscription
            viewSubscriptionModel.subscription = subscription
        }
    }

    private let buttonScrollToBottomSize = CGFloat(70)
    lazy var buttonScrollToBottom: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: .greatestFiniteMagnitude, y: .greatestFiniteMagnitude, width: buttonScrollToBottomSize, height: buttonScrollToBottomSize)
        button.setImage(UIImage(named: "Float Button light"), for: .normal)
        button.addTarget(self, action: #selector(buttonScrollToBottomDidPressed), for: .touchUpInside)
        return button
    }()

    var scrollToBottomButtonIsVisible: Bool = false {
        didSet {
            guard oldValue != scrollToBottomButtonIsVisible
            else {
                return
            }

            func animates(_ animations: @escaping VoidCompletion) {
                UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: {
                    animations()
                }, completion: nil)
            }

            if self.scrollToBottomButtonIsVisible {
                if buttonScrollToBottom.superview == nil {
                    view.addSubview(buttonScrollToBottom)
                }

                var frame = buttonScrollToBottom.frame
                frame.origin.x = collectionView.frame.width - buttonScrollToBottomSize - view.layoutMargins.right
                frame.origin.y = collectionView.frame.origin.y + collectionView.frame.height - buttonScrollToBottomSize - collectionView.layoutMargins.top - composerView.frame.height

                animates({
                    self.buttonScrollToBottom.frame = frame
                    self.buttonScrollToBottom.alpha = 1
                })
            } else {
                var frame = buttonScrollToBottom.frame
                frame.origin.x = collectionView.frame.width - buttonScrollToBottomSize - view.layoutMargins.right
                frame.origin.y = collectionView.frame.origin.y + collectionView.frame.height

                animates({
                    self.buttonScrollToBottom.frame = frame
                    self.buttonScrollToBottom.alpha = 0
                })
            }
        }
    }

    lazy var screenSize = view.frame.size

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.addObserver(self)
        composerView.delegate = self

        collectionView.register(BasicMessageCell.nib, forCellWithReuseIdentifier: BasicMessageCell.identifier)
        collectionView.register(SequentialMessageCell.nib, forCellWithReuseIdentifier: SequentialMessageCell.identifier)
        collectionView.register(DateSeparatorCell.nib, forCellWithReuseIdentifier: DateSeparatorCell.identifier)
        collectionView.register(UnreadMarkerCell.nib, forCellWithReuseIdentifier: UnreadMarkerCell.identifier)
        collectionView.register(AudioCell.nib, forCellWithReuseIdentifier: AudioCell.identifier)
        collectionView.register(AudioMessageCell.nib, forCellWithReuseIdentifier: AudioMessageCell.identifier)
        collectionView.register(VideoCell.nib, forCellWithReuseIdentifier: VideoCell.identifier)
        collectionView.register(VideoMessageCell.nib, forCellWithReuseIdentifier: VideoMessageCell.identifier)
        collectionView.register(ReactionsCell.nib, forCellWithReuseIdentifier: ReactionsCell.identifier)
        collectionView.register(FileCell.nib, forCellWithReuseIdentifier: FileCell.identifier)
        collectionView.register(FileMessageCell.nib, forCellWithReuseIdentifier: FileMessageCell.identifier)
        collectionView.register(TextAttachmentCell.nib, forCellWithReuseIdentifier: TextAttachmentCell.identifier)
        collectionView.register(TextAttachmentMessageCell.nib, forCellWithReuseIdentifier: TextAttachmentMessageCell.identifier)
        collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.register(ImageMessageCell.nib, forCellWithReuseIdentifier: ImageMessageCell.identifier)
        collectionView.register(QuoteCell.nib, forCellWithReuseIdentifier: QuoteCell.identifier)
        collectionView.register(QuoteMessageCell.nib, forCellWithReuseIdentifier: QuoteMessageCell.identifier)
        collectionView.register(MessageURLCell.nib, forCellWithReuseIdentifier: MessageURLCell.identifier)
        collectionView.register(MessageActionsCell.nib, forCellWithReuseIdentifier: MessageActionsCell.identifier)

        view.bringSubviewToFront(buttonScrollToBottom)

        dataUpdateDelegate = self
        viewModel.controllerContext = self
        viewModel.onDataChanged = {
            Log.debug("[VIEW MODEL] dataChanged with \(self.viewModel.dataNormalized.count) values.")
            self.updateData(with: self.viewModel.dataNormalized)
        }

        viewSubscriptionModel.onDataChanged = {
            // TODO: handle updates on the Subscription object, such like title view
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        markAsRead()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let topIndexPath = visibleIndexPaths.sorted().last

        screenSize = size
        let shouldResetScrollToBottom = scrollToBottomButtonIsVisible

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.viewSizingModel.clearCache()
            self?.collectionView.reloadData()
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }

            if shouldResetScrollToBottom {
                if self.scrollToBottomButtonIsVisible {
                    self.scrollToBottomButtonIsVisible = false
                    self.scrollToBottomButtonIsVisible = true
                }
            }

            if let indexPath = topIndexPath {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        })
    }

    @objc func buttonScrollToBottomDidPressed() {
        scrollToBottom(true)
    }

    @objc internal func scrollToBottom(_ animated: Bool = false) {
        let offset = CGPoint(x: 0, y: -composerView.frame.height)
        collectionView.setContentOffset(offset, animated: animated)
        scrollToBottomButtonIsVisible = false
    }

    internal func resetScrollToBottomButtonPosition() {
        scrollToBottomButtonIsVisible = !chatLogIsAtBottom()
    }

    private func chatLogIsAtBottom() -> Bool {
        return collectionView.contentOffset.y <= -composerView.frame.height
    }

    func openURL(url: URL) {
        WebBrowserManager.open(url: url)
    }

    private func markAsRead() {
        guard let subscription = viewModel.subscription?.validated()?.unmanaged else { return }
        API.current()?.client(SubscriptionsClient.self).markAsRead(subscription: subscription)
    }

}

extension MessagesViewController {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.numberOfSections - indexPath.section <= 5 {
            viewModel.fetchMessages(from: viewModel.oldestMessageDateBeingPresented)
        }

        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = viewModel.item(for: indexPath) else {
            return .zero
        }

        if let size = viewSizingModel.size(for: item.differenceIdentifier) {
            return size
        } else {
            guard let sizingCell = UINib(nibName: item.relatedReuseIdentifier, bundle: nil).instantiate() as? SizingCell else {
                fatalError("""
                            Failed to reference sizing cell instance. Please,
                            check the relatedReuseIdentifier and make sure all
                            the chat components conform to SizingCell protocol
                            """)
            }

            let horizontalMargins = collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right
            var size = type(of: sizingCell).size(for: item, with: horizontalMargins)
            size = CGSize(width: screenSize.width - horizontalMargins, height: size.height)
            viewSizingModel.set(size: size, for: item.differenceIdentifier)
            return size
        }
    }

}

extension MessagesViewController: ChatDataUpdateDelegate {

    func didUpdateChatData(newData: [AnyChatSection]) {
        viewModel.data = newData
        viewModel.updateData(shouldUpdateUI: false)
    }

}

extension MessagesViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resetScrollToBottomButtonPosition()
    }

}

extension MessagesViewController: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}

extension MessagesViewController: UserActionSheetPresenter {

    func presentActionSheetForUser(_ user: User, source: (view: UIView?, rect: CGRect?)?) {
        presentActionSheetForUser(user, subscription: subscription, source: source)
    }

}

extension MessagesViewController {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = view.theme else { return }
        let themeName = ThemeManager.themes.first { $0.theme == theme }?.title
        let scrollToBottomImageName = "Float Button " + (themeName ?? "light")
        buttonScrollToBottom.setImage(UIImage(named: scrollToBottomImageName), for: .normal)
    }
}
