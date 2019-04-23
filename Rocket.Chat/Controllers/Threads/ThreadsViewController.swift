//
//  ThreadsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 22/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

private typealias NibCellIndentifier = (nib: UINib, cellIdentifier: String)

final class ThreadsViewController: RocketChatViewController, MessagesListProtocol {

    let viewModel = ThreadsViewModel()
    let viewSizingModel = MessagesSizingManager()

    lazy var screenSize = view.frame.size
    var isInLandscape: Bool {
        return screenSize.width / screenSize.height > 1 && UIDevice.current.userInterfaceIdiom == .phone
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isInverted = false

        registerCells()
        removeComposer()

        loadMoreData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let topIndexPath = visibleIndexPaths.sorted().last

        screenSize = size

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.viewSizingModel.clearCache()
            self?.collectionView.reloadData()
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }

            if let indexPath = topIndexPath {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        })
    }

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
            (nib: MessageVideoCallCell.nib, cellIdentifier: MessageVideoCallCell.identifier),
            (nib: MessageDiscussionCell.nib, cellIdentifier: MessageDiscussionCell.identifier),
            (nib: MessageMainThreadCell.nib, cellIdentifier: MessageMainThreadCell.identifier),
            (nib: ThreadReplyCollapsedCell.nib, cellIdentifier: ThreadReplyCollapsedCell.identifier),
            (nib: HeaderCell.nib, cellIdentifier: HeaderCell.identifier)
        ]

        collectionViewCells.forEach {
            collectionView?.register($0.nib, forCellWithReuseIdentifier: $0.cellIdentifier)
        }
    }

    private func removeComposer() {
        composerHeightConstraint?.constant = 0
        composerView.removeFromSuperview()
    }

    // MARK: Data Management

    func loadMoreData() {
        let activity = UIActivityIndicatorView(style: .gray)
        let buttonActivity = UIBarButtonItem(customView: activity)
        activity.startAnimating()
        navigationItem.rightBarButtonItem = buttonActivity

        viewModel.controllerContext = self
        viewModel.loadMoreObjects { [weak self] in
            guard let self = self else { return }

            self.navigationItem.rightBarButtonItem = nil
            self.updateData(with: self.viewModel.dataNormalized)
        }
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

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfObjects
    }

}

extension ThreadsViewController: ChatDataUpdateDelegate {

    func didUpdateChatData(newData: [AnyChatSection], updatedItems: [AnyHashable]) {
        updatedItems.forEach { viewSizingModel.invalidateLayout(for: $0) }
        viewModel.data = newData
        viewModel.normalizeData()
    }

}

extension ThreadsViewController {

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
