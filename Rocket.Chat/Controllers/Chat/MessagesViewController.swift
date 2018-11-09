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
    static func size(for viewModel: AnyChatItem, with cellWidth: CGFloat) -> CGSize
}

extension SizingCell {
    static func size(for viewModel: AnyChatItem, with cellWidth: CGFloat) -> CGSize {
        var mutableSizingCell = sizingCell
        mutableSizingCell.prepareForReuse()
        mutableSizingCell.messageWidth = cellWidth
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

    // TODO: Move to another view model
    let socketHandlerToken = String.random(5)

    var chatTitleView: ChatTitleView?

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
    var isInLandscape: Bool {
        return screenSize.width / screenSize.height > 1 && UIDevice.current.userInterfaceIdiom == .phone
    }

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleView()

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        ThemeManager.addObserver(self)
        ThemeManager.addObserver(composerView)

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
        viewModel.onDataChanged = { [weak self] in
            guard let self = self else { return }
            Log.debug("[VIEW MODEL] dataChanged with \(self.viewModel.dataNormalized.count) values.")

            // Update dataset with the new data normalized
            self.updateData(with: self.viewModel.dataNormalized)
        }

        viewSubscriptionModel.onDataChanged = { [weak self] in
            guard let self = self else { return }
            self.chatTitleView?.subscription = self.viewSubscriptionModel.subscription
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Channel Actions", let nav = segue.destination as? UINavigationController {
            if let controller = nav.viewControllers.first as? ChannelActionsViewController {
                if let subscription = self.subscription {
                    controller.subscription = subscription
                }
            }
        }
    }

    // MARK: Pagination

    func loadNextPageIfNeeded() {
        guard let collectionView = collectionView else { return }

        let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height
        if bottomEdge >= collectionView.contentSize.height - 200 {
            viewModel.fetchMessages(from: viewModel.oldestMessageDateFromRemote)
        }
    }

    // MARK: TitleView

    private func setupTitleView() {
        let view = ChatTitleView.instantiateFromNib()
        view?.subscription = subscription
        view?.delegate = self
        navigationItem.titleView = view
        chatTitleView = view
        chatTitleView?.applyTheme()
    }

    // MARK: IBAction

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

    // MARK: Reading Status

    private func markAsRead() {
        guard let subscription = viewModel.subscription?.validated()?.unmanaged else { return }
        API.current()?.client(SubscriptionsClient.self).markAsRead(subscription: subscription)
    }

    // MARK: Sizing

    func messageWidth() -> CGFloat {
        var horizontalMargins: CGFloat
        if isInLandscape {
            horizontalMargins = collectionView.adjustedContentInset.top + collectionView.adjustedContentInset.bottom
        } else {
            horizontalMargins = 0
        }

        return screenSize.width - horizontalMargins
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

            let cellWidth = messageWidth()
            var size = type(of: sizingCell).size(for: item, with: cellWidth)
            size = CGSize(width: cellWidth, height: size.height)
            viewSizingModel.set(size: size, for: item.differenceIdentifier)
            return size
        }
    }

}

extension MessagesViewController: ChatDataUpdateDelegate {

    func didUpdateChatData(newData: [AnyChatSection], updatedItems: [AnyHashable]) {
        updatedItems.forEach { viewSizingModel.invalidateLayout(for: $0) }
        viewModel.data = newData
        viewModel.updateData(shouldUpdateUI: false)
    }

}

extension MessagesViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resetScrollToBottomButtonPosition()
        loadNextPageIfNeeded()
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

extension MessagesViewController: ChatTitleViewProtocol {

    func titleViewChannelButtonPressed() {
        performSegue(withIdentifier: "Channel Actions", sender: nil)
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

extension MessagesViewController: SocketConnectionHandler {

    func socketDidChangeState(state: SocketConnectionState) {
        Log.debug("[ChatViewController] socketDidChangeState: \(state)")
        chatTitleView?.state = state

        if state == .connected {
            viewModel.requestingData = false
            viewModel.fetchMessages(from: nil)
        }
    }

}
