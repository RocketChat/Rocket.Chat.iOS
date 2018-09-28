//
//  RocketChatViewController.swift
//  RocketChatViewController Example
//
//  Created by Rafael Kellermann Streit on 30/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import DifferenceKit

fileprivate extension NSNotification.Name {
    static let triggerDataUpdate = NSNotification.Name("TRIGGER_DATA_UPDATE")
}

public extension UICollectionView {
    public func dequeueChatCell(withReuseIdentifier reuseIdetifier: String, for indexPath: IndexPath) -> ChatCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdetifier, for: indexPath) as? ChatCell else {
            fatalError("Trying to dequeue a reusable UICollectionViewCell that doesn't conforms to BindableCell protocol")
        }

        return cell
    }
}

/**
    A type-erased ChatCellViewModel that must conform to the Differentiable protocol.

    The `AnyChatCellViewModel` type forwards equality comparisons and utilities operations or properties
    such as relatedReuseIdentifier to an underlying differentiable value,
    hiding its specific underlying type.
 */

public struct AnyChatItem: ChatItem, Differentiable {
   public var relatedReuseIdentifier: String {
        return base.relatedReuseIdentifier
    }

    public let base: ChatItem
    public let differenceIdentifier: AnyHashable

    let isUpdatedFrom: (AnyChatItem) -> Bool

    public init<D: Differentiable & ChatItem>(_ base: D) {
        self.base = base
        self.differenceIdentifier = AnyHashable(base.differenceIdentifier)

        self.isUpdatedFrom = { source in
            guard let sourceBase = source.base as? D else { return false }
            return base.isContentEqual(to: sourceBase)
        }
    }

    public func isContentEqual(to source: AnyChatItem) -> Bool {
        return isUpdatedFrom(source)
    }
}

/**
    A type-erased SectionController.

    The `AnySectionController` type forwards equality comparisons and servers as a data source
    for RocketChatViewController to build one section, hiding its specific underlying type.
 */

public struct AnyChatSection: ChatSection {
    public weak var controllerContext: UIViewController? {
        get {
            return base.controllerContext
        }

        set(newControllerContext) {
            base.controllerContext = newControllerContext
        }
    }

    public var object: AnyDifferentiable {
        return base.object
    }

    public var base: ChatSection

    public init<D: ChatSection>(_ base: D) {
        self.base = base
    }

    public func viewModels() -> [AnyChatItem] {
        return base.viewModels()
    }

    public func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell {
        return base.cell(for: viewModel, on: collectionView, at: indexPath)
    }
}

extension AnyChatSection: Differentiable {
    public var differenceIdentifier: AnyHashable {
        return AnyHashable(base.object.differenceIdentifier)
    }

    public func isContentEqual(to source: AnyChatSection) -> Bool {
        return base.object.isContentEqual(to: source.object)
    }
}

fileprivate extension AnyChatSection {
    var toArraySection: ArraySection<AnyChatSection, AnyChatItem> {
        return ArraySection(model: self, elements: viewModels())
    }
}

/**
    The responsible for implementing the data source of a single section
    which represents an object splitted into differentiable view models
    each one being binded on a reusable UICollectionViewCell that get updated when there's
    something to update on its content.

    A SectionController is also responsible for handling the actions
    and interactions with the object related to it.

    A SectionController's object is meant to be immutable.
 */

public protocol ChatSection {
    var object: AnyDifferentiable { get }
    var controllerContext: UIViewController? { get set }
    func viewModels() -> [AnyChatItem]
    func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell
}

public extension ChatSection {
    public func update() {
        NotificationCenter.default.post(
            name: .triggerDataUpdate,
            object: nil
        )
    }
}

/**
    A single split of an object that binds an UICollectionViewCell and can be differentiated.

    A ChatCellViewModel also holds the related UICollectionViewCell's reuseIdentifier.
 */

public protocol ChatItem {
    var relatedReuseIdentifier: String { get }
}

public extension ChatItem where Self: Differentiable {
    // In order to use a ChatCellViewModel along with a SectionController
    // we must use it as a type-erased ChatCellViewModel, which in this case also means
    // that it must conform to the Differentiable protocol.
    public var wrapped: AnyChatItem {
        return AnyChatItem(self)
    }
}

/**
    A protocol that must be implemented by all cells to padronize the way we bind the data on its view.
 */

public protocol ChatCell {
    var viewModel: AnyChatItem? { get set }
    func configure()
}

public protocol ChatDataUpdateDelegate: class {
    func didUpdateChatData(newData: [AnyChatSection])
}

/**
    RocketChatViewController is basically a UIViewController that holds
    two key components: a list and a message composer.

    The whole idea is to keep the list as close as possible to a regular UICollectionView,
    but with some features and add-ons to make it more "chat friendly" in the point of view of
    performance, modularity and flexibility.

    To solve modularity (and help with performance) we've created a set of protocols
    and wrappers that ensure that we treat each object as a section of our list
    then break it down as much as possible into subobjects that can be differentiated.

    Bringing it to the chat concept, each message is a section, each section can have one
    or more items, it will depend on the complexity of each message. For example, if it's a simple
    text-only message we can represent it using a single reusable cell for this message's section,
    on the other hand if the message has attachments or multimedia content, it's better to
    split the most basic components of a message (avatar, username and text) into a reusable cell
    and the multimedia content (video, image, link preview, etc) into other reusable cells. This
    way we will wind up with simpler cells that cost less to reuse.

    To solve performance our main efforts are concentrated on updating the views the least
    possible. In order to do that we rely on a third-party (awesome) diffing library
    called DifferenceKit. Based on the benchmarks provided on its GitHub page it is the most
    performatic diffing library available for iOS development now. DifferenceKit also provides a
    UICollectionView extension that performs batch updates based on a changeset making sure that
    only the items that changed are going to be refreshed. On top of DifferenceKit's reloading
    we've implemented a simple operation queue to guarantee that no more than one reload will run
    at once.

    To solve flexibility we thought a lot on how to do the things above but yet keep it a regular
    UICollectionView for those who just want to implement their own list, and we decided that we would
    manage the UICollectionViewDataSource through a public `data` property that reflects on a private `internalData`
    property. This way on a subclass of RocketChatViewController we just need to process the data and set to the `data`
    property that the superclass implementation will handle the data source and will be able to apply the custom reload
    method managed by our operation queue. On the other hand, if anyone wants to implement their message list without
    having to conform to DifferenceKit and our protocols, he just need to override the UICollectionViewDataSource methods
    and provide a custom implementation.

    Minor features:
    - Inverted mode
    - Self-sizing cells support

 */

open class RocketChatViewController: UICollectionViewController {
    open var composerHeightConstraint: NSLayoutConstraint!
    open var composerView = ComposerView()

    open override var inputAccessoryView: UIView? {
        composerView.layoutMargins = view.layoutMargins
        composerView.directionalLayoutMargins = systemMinimumLayoutMargins
        
        return composerView
    }

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open var data: [AnyChatSection] = []
    private var internalData: [ArraySection<AnyChatSection, AnyChatItem>] = []

    open weak var dataUpdateDelegate: ChatDataUpdateDelegate?
    private let updateDataQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .background

        return operationQueue
    }()

    open var isInverted = true
    open var isSelfSizing = false
    private let invertedTransform = CGAffineTransform(scaleX: 1, y: -1)

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupChatViews()
        registerObservers()
        startAvoidingKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(updateData),
            name: .triggerDataUpdate,
            object: nil
        )
    }

    func setupChatViews() {
        guard let collectionView = collectionView else {
            return
        }

        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.backgroundColor = .white

        collectionView.transform = isInverted ? invertedTransform : collectionView.transform

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInsetAdjustmentBehavior = .always

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, isSelfSizing {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
    }

    @objc open func updateData() {
        updateDataQueue.addOperation { [weak self] in
            guard
                let strongSelf = self,
                let collectionView = strongSelf.collectionView
            else {
                return
            }

            DispatchQueue.main.async {
                let changeset = StagedChangeset(source: strongSelf.internalData, target: strongSelf.data.map({ $0.toArraySection }))
                collectionView.reload(using: changeset, updateRows: { indexPaths in
                    for indexPath in indexPaths {
                        if collectionView.indexPathsForVisibleItems.contains(indexPath),
                            var cell = collectionView.cellForItem(at: indexPath) as? ChatCell {
                            let viewModel = strongSelf.internalData[indexPath.section].elements[indexPath.item]
                            cell.viewModel = viewModel
                            cell.configure()
                        }
                    }
                }, interrupt: { $0.changeCount > 100 }) { newData in
                    strongSelf.internalData = newData

                    let newSections = newData.map { $0.model }
                    strongSelf.data = newSections
                    strongSelf.dataUpdateDelegate?.didUpdateChatData(newData: newSections)
                }
            }
        }
    }
}

extension RocketChatViewController {
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return internalData.count
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return internalData[section].elements.count
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionController = internalData[indexPath.section].model
        let viewModel = sectionController.viewModels()[indexPath.row]

        guard let chatCell = sectionController.cell(for: viewModel, on: collectionView, at: indexPath) as? UICollectionViewCell else {
            fatalError("The object conforming to BindableCell is not a UICollectionViewCell as it must be")
        }

        return chatCell
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.transform = isInverted ? invertedTransform : cell.contentView.transform
    }
}

extension RocketChatViewController: UICollectionViewDelegateFlowLayout {}


extension RocketChatViewController {
    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                  object: nil)
    }

    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.top)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.top = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
