//
//  HintsView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public protocol HintsViewDelegate: class {
    func numberOfHints(in hintsView: HintsView) -> Int
    func maximumHeight(for hintsView: HintsView) -> CGFloat
    func hintsView(_ hintsView: HintsView, cellForHintAt index: Int) -> UITableViewCell
    func title(for hintsView: HintsView) -> String?

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int)
}

public extension HintsViewDelegate {
    func title(for hintsView: HintsView) -> String? {
        return "Suggestions"
    }

    func maximumHeight(for hintsView: HintsView) -> CGFloat {
        return 300
    }
}

private final class HintsViewFallbackDelegate: HintsViewDelegate {
    func numberOfHints(in hintsView: HintsView) -> Int {
        return 0
    }

    func hintsView(_ hintsView: HintsView, cellForHintAt index: Int) -> UITableViewCell {
        return UITableViewCell()
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {

    }
}

public class HintsView: UITableView {
    public weak var hintsDelegate: HintsViewDelegate?
    private var fallbackDelegate: HintsViewDelegate = HintsViewFallbackDelegate()

    private var currentDelegate: HintsViewDelegate {
        return hintsDelegate ?? fallbackDelegate
    }

    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()

            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        if numberOfRows(inSection: 0) == 0 {
            return CGSize(width: contentSize.width, height: 0)
        }

        return CGSize(width: contentSize.width, height: min(contentSize.height, currentDelegate.maximumHeight(for: self)))
    }

    public init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func registerCellTypes(_ cellType: UITableViewCell.Type...) {
        cellType.forEach { register($0, forCellReuseIdentifier: "\($0)") }
    }

    public func dequeueReusableCell<T: UITableViewCell>(withType cellType: T.Type) -> T {
        let dequeue = { self.dequeueReusableCell(withIdentifier: "\(cellType)") as? T }

        if let cell = dequeue() {
            return cell
        } else {
            registerCellTypes(cellType)
        }

        if let cell = dequeue() {
            return cell
        }

        fatalError("[HintsView] Could not dequeue cell of type: '\(cellType)'")
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil, using: { [weak self] _ in
            self?.beginUpdates()
            self?.endUpdates()
        })

        dataSource = self
        delegate = self
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 44
        separatorInset = UIEdgeInsets(
            top: 0,
            left: 8,
            bottom: 0,
            right: 0
        )

        register(
            UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: "header"
        )

        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {

    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

        ])
    }
}

extension HintsView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDelegate.numberOfHints(in: self)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currentDelegate.hintsView(self, cellForHintAt: indexPath.row)
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 54,
            bottom: 0,
            right: 0
        )
        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentDelegate.title(for: self)
    }
}

extension HintsView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentDelegate.hintsView(self, didSelectHintAt: indexPath.row)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }

        header.backgroundView?.backgroundColor = backgroundColor
        header.textLabel?.text = currentDelegate.title(for: self)
        header.textLabel?.textColor = #colorLiteral(red: 0.6196078431, green: 0.6352941176, blue: 0.6588235294, alpha: 1)
    }
}
