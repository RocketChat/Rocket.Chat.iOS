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

private typealias NibCellIndentifier = (nib: UINib, cellIdentifier: String)

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
        mutableSizingCell.configure(completeRendering: false)
        mutableSizingCell.setNeedsLayout()
        mutableSizingCell.layoutIfNeeded()
        return mutableSizingCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

final class MessagesViewController: RocketChatViewController {

    @objc override var bottomHeight: CGFloat {
        if subscription?.isJoined() ?? true {
            return super.bottomHeight
        }

        return (chatPreviewModeView?.frame.height ?? 0.0) + view.safeAreaInsets.bottom
    }

    let viewModel = MessagesViewModel(controllerContext: nil)
    let viewSubscriptionModel = MessagesSubscriptionViewModel()
    let viewSizingModel = MessagesSizingManager()
    let composerViewModel = MessagesComposerViewModel()

    // TODO: Move to another view model
    let socketHandlerToken = String.random(5)

    var chatTitleView: ChatTitleView?

    var chatPreviewModeView: ChatPreviewModeView?

    var emptyStateImageView: UIImageView?
    var documentController: UIDocumentInteractionController?

    var unmanagedSubscription: UnmanagedSubscription?
    var subscription: Subscription! {
        didSet {
            let sub: Subscription? = subscription
            let unmanaged = sub?.unmanaged

            viewModel.subscription = sub
            viewSubscriptionModel.subscription = unmanaged
            unmanagedSubscription = unmanaged

            recoverDraftMessage()
            updateEmptyState()
        }
    }

    private let buttonScrollToBottomSize = CGFloat(70)
    var keyboardHeight: CGFloat = 0
    var buttonScrollToBottomConstraint: NSLayoutConstraint!
    var buttonScrollToBottomLayerY: CGFloat {
        return -composerView.layer.bounds.height - buttonScrollToBottomSize / 2 - collectionView.layoutMargins.top - keyboardHeight
    }
    var buttonScrollToBottomY: CGFloat {
        return -composerView.intrinsicContentSize.height - collectionView.layoutMargins.top - keyboardHeight
    }

    lazy var buttonScrollToBottom: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: .greatestFiniteMagnitude, y: .greatestFiniteMagnitude, width: buttonScrollToBottomSize, height: buttonScrollToBottomSize)
        button.setImage(UIImage(named: "Float Button light"), for: .normal)
        button.addTarget(self, action: #selector(buttonScrollToBottomDidPressed), for: .touchUpInside)
        return button
    }()

    var isScrollingToBottom: Bool = false
    var scrollToBottomButtonIsVisible: Bool = false

    lazy var screenSize = view.frame.size
    var isInLandscape: Bool {
        return screenSize.width / screenSize.height > 1 && UIDevice.current.userInterfaceIdiom == .phone
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    var allowResignFirstResponder = true
    override var canResignFirstResponder: Bool {
        return allowResignFirstResponder
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleView()
        updateEmptyState()
        updateSearchMessagesButton()

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        ThemeManager.addObserver(self)
        ThemeManager.addObserver(composerView)

        composerView.delegate = self

        registerCells()
        setupScrollToBottom()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        dataUpdateDelegate = self
        viewModel.controllerContext = self
        viewModel.onDataChanged = { [weak self] in
            guard let self = self else { return }
            Log.debug("[VIEW MODEL] dataChanged with \(self.viewModel.dataNormalized.count) values.")

            if self.viewModel.dataNormalized.first?.model.differenceIdentifier == AnyHashable(HeaderChatItem.globalIdentifier) {
                self.isInverted = false
            } else {
                self.isInverted = true
            }

            // Update dataset with the new data normalized
            self.updateData(with: self.viewModel.dataNormalized)
            self.markAsRead()
        }

        viewSubscriptionModel.onDataChanged = { [weak self] in
            guard let self = self else { return }
            self.chatTitleView?.subscription = self.viewSubscriptionModel.subscription
            self.updateJoinedView()

            if self.viewSubscriptionModel.subscription?.managedObject == nil {
                self.navigationController?.popToRootViewController(animated: true)
                self.subscription = nil
            }
        }

        viewSubscriptionModel.onTypingChanged = { [weak self] usernames in
            DispatchQueue.main.async {
                self?.chatTitleView?.updateTypingStatus(usernames: usernames)
            }
        }

        composerViewModel.getRecentSenders = { [weak self] in
            guard let self = self else {
                return []
            }

            return self.viewModel.recentSenders
        }

        startDraftMessage()
        updateJoinedView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        markAsRead()
        becomeFirstResponder()
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
                    self.showScrollToBottom(forceUpdate: true)
                }
            }

            if let indexPath = topIndexPath {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmptyStateFrame()
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

    // MARK: Cells

    private func registerCells() {
        let collectionViewCells: [NibCellIndentifier] = [
            (nib: BasicMessageCell.nib, cellIdentifier: BasicMessageCell.identifier),
            (nib: SequentialMessageCell.nib, cellIdentifier: SequentialMessageCell.identifier),
            (nib: LoaderCell.nib, cellIdentifier: LoaderCell.identifier),
            (nib: DateSeparatorCell.nib, cellIdentifier: DateSeparatorCell.identifier),
            (nib: UnreadMarkerCell.nib, cellIdentifier: UnreadMarkerCell.identifier),
            (nib: AudioCell.nib, cellIdentifier: AudioCell.identifier),
            (nib: AudioMessageCell.nib, cellIdentifier: AudioMessageCell.identifier),
            (nib: VideoCell.nib, cellIdentifier: VideoCell.identifier),
            (nib: VideoMessageCell.nib, cellIdentifier: VideoMessageCell.identifier),
            (nib: ReactionsCell.nib, cellIdentifier: ReactionsCell.identifier),
            (nib: FileCell.nib, cellIdentifier: FileCell.identifier),
            (nib: FileMessageCell.nib, cellIdentifier: FileMessageCell.identifier),
            (nib: TextAttachmentCell.nib, cellIdentifier: TextAttachmentCell.identifier),
            (nib: TextAttachmentMessageCell.nib, cellIdentifier: TextAttachmentMessageCell.identifier),
            (nib: ImageCell.nib, cellIdentifier: ImageCell.identifier),
            (nib: ImageMessageCell.nib, cellIdentifier: ImageMessageCell.identifier),
            (nib: QuoteCell.nib, cellIdentifier: QuoteCell.identifier),
            (nib: QuoteMessageCell.nib, cellIdentifier: QuoteMessageCell.identifier),
            (nib: MessageURLCell.nib, cellIdentifier: MessageURLCell.identifier),
            (nib: MessageActionsCell.nib, cellIdentifier: MessageActionsCell.identifier),
            (nib: HeaderCell.nib, cellIdentifier: HeaderCell.identifier)
        ]

        collectionViewCells.forEach {
            collectionView?.register($0.nib, forCellWithReuseIdentifier: $0.cellIdentifier)
        }
    }

    // MARK: Scroll to Bottom

    func setupScrollToBottom() {
        buttonScrollToBottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonScrollToBottom)
        view.bringSubviewToFront(buttonScrollToBottom)
        buttonScrollToBottomConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        NSLayoutConstraint.activate([
            buttonScrollToBottom.heightAnchor.constraint(equalToConstant: buttonScrollToBottomSize),
            buttonScrollToBottom.widthAnchor.constraint(equalToConstant: buttonScrollToBottomSize),
            buttonScrollToBottomConstraint,
            buttonScrollToBottom.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ])
    }

    func showScrollToBottom(forceUpdate: Bool = false) {
        let isScrollToBottomVisible = forceUpdate ? false : scrollToBottomButtonIsVisible
        guard !isScrollToBottomVisible, !isScrollingToBottom else {
            return
        }

        isScrollingToBottom = true
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        CATransaction.setCompletionBlock {
            self.buttonScrollToBottomConstraint.constant = self.buttonScrollToBottomY
            self.scrollToBottomButtonIsVisible = true
            self.isScrollingToBottom = false
        }

        var fromPosition = buttonScrollToBottom.layer.position
        fromPosition.y -= keyboardHeight
        var position = buttonScrollToBottom.layer.position
        position.y = collectionView.bounds.height + buttonScrollToBottomLayerY

        let positionAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        positionAnimation.fromValue = fromPosition
        positionAnimation.toValue = position

        buttonScrollToBottom.layer.position = position
        buttonScrollToBottom.layer.add(positionAnimation, forKey: #keyPath(CALayer.position))

        let alphaAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnimation.fromValue = 0
        alphaAnimation.toValue = 1

        buttonScrollToBottom.layer.opacity = 1
        buttonScrollToBottom.layer.add(alphaAnimation, forKey: #keyPath(CALayer.opacity))

        CATransaction.commit()
    }

    func hideScrollToBottom(forceUpdate: Bool = false) {
        let isScrollToBottomVisible = forceUpdate ? true : scrollToBottomButtonIsVisible
        guard isScrollToBottomVisible, !isScrollingToBottom else {
            return
        }

        isScrollingToBottom = true
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        CATransaction.setCompletionBlock {
            self.buttonScrollToBottomConstraint.constant = 200
            self.scrollToBottomButtonIsVisible = false
            self.isScrollingToBottom = false
        }

        var position = buttonScrollToBottom.layer.position
        position.y = collectionView.bounds.height + 200

        let positionAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        positionAnimation.fromValue = buttonScrollToBottom.layer.position
        positionAnimation.toValue = position

        buttonScrollToBottom.layer.position = position
        buttonScrollToBottom.layer.add(positionAnimation, forKey: #keyPath(CALayer.position))

        let alphaAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0

        buttonScrollToBottom.layer.opacity = 0
        buttonScrollToBottom.layer.add(alphaAnimation, forKey: #keyPath(CALayer.opacity))

        CATransaction.commit()
    }

    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height - composerView.intrinsicContentSize.height

            if scrollToBottomButtonIsVisible {
                showScrollToBottom(forceUpdate: true)
            }
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        if scrollToBottomButtonIsVisible {
            showScrollToBottom(forceUpdate: true)
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
        view?.subscription = subscription?.unmanaged
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
        let offset = CGPoint(x: 0, y: -composerView.frame.height - keyboardHeight)
        collectionView.setContentOffset(offset, animated: animated)
        hideScrollToBottom()
    }

    internal func resetScrollToBottomButtonPosition() {
        guard !isScrollingToBottom else { return }
        if !chatLogIsAtBottom() {
            showScrollToBottom()
        } else {
            hideScrollToBottom()
        }
    }

    private func chatLogIsAtBottom() -> Bool {
        return (collectionView.contentOffset.y + keyboardHeight) <= -composerView.frame.height
    }

    // MARK: Reading Status

    private func markAsRead() {
        guard let subscription = unmanagedSubscription else { return }
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
            let identifier = item.relatedReuseIdentifier
            var sizingCell: Any?

            if let cachedSizingCell = viewSizingModel.view(for: identifier) as? SizingCell {
                sizingCell = cachedSizingCell
            } else {
                sizingCell = UINib(nibName: identifier, bundle: nil).instantiate() as? SizingCell

                if let sizingCell = sizingCell {
                    viewSizingModel.set(view: sizingCell, for: identifier)
                }
            }

            guard let cell = sizingCell as? SizingCell else {
                fatalError("""
                    Failed to reference sizing cell instance. Please,
                    check the relatedReuseIdentifier and make sure all
                    the chat components conform to SizingCell protocol
                """)
            }

            let cellWidth = messageWidth()
            var size = type(of: cell).size(for: item, with: cellWidth)
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
        if scrollView.isDragging {
            resetScrollToBottomButtonPosition()
        }

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

        emptyStateImageView?.image = UIImage(named: "Empty State \(themeName ?? "light")")
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
