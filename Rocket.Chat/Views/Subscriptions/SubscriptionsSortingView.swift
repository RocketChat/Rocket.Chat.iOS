//
//  SubscriptionsSortingView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionsSortingView: UIView {

    private let viewModel = SubscriptionsSortingViewModel()

    @IBOutlet weak var tappableView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            tappableView.addGestureRecognizer(tapGesture)
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    // Start the constraint with negative value (view height + headerView height) so we can
    // animate it later when the view is presented.
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeighConstraint.constant = viewModel.initialTableViewPosition
        }
    }

    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeighConstraint.constant = viewModel.viewHeight
        }
    }

    private func animates(_ animations: @escaping VoidCompletion, completion: VoidCompletion? = nil) {
        UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(rawValue: 7 << 16), animations: {
            animations()
        }, completion: { finished in
            if finished {
                completion?()
            }
        })
    }

    // MARK: Showing the View

    static func showIn(_ view: UIView) -> SubscriptionsSortingView? {
        guard let instance = SubscriptionsSortingView.instantiateFromNib() else { return nil }
        instance.backgroundColor = UIColor.black.withAlphaComponent(0)
        instance.frame = view.bounds
        view.addSubview(instance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            instance.tableViewTopConstraint.constant = 0

            instance.animates({
                instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                instance.layoutIfNeeded()
            })
        }

        return instance
    }

    // MARK: Hiding the View

    @objc func close() {
        tableViewTopConstraint.constant = viewModel.initialTableViewPosition

        animates({
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: {
            self.removeFromSuperview()
        })
    }

}

// MARK: UITapGestureDelegate

extension SubscriptionsSortingView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

// MARK: UITableViewDataSource

extension SubscriptionsSortingView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.identifier) as? ServerCell else {
            return UITableViewCell()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServerCell.cellHeight
    }

}

// MARK: UITableViewDelegate

extension SubscriptionsSortingView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
