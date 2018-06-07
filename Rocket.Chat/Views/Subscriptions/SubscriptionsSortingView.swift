//
//  SubscriptionsSortingView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionsSortingViewDelegate: class {
    func userDidChangeSortingOptions()
}

final class SubscriptionsSortingView: UIView {

    weak var delegate: SubscriptionsSortingViewDelegate?

    private let viewModel = SubscriptionsSortingViewModel()

    @IBOutlet weak var tappableView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            tappableView.addGestureRecognizer(tapGesture)
        }
    }

    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = viewModel.sortingTitleDescription
        }
    }

    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self

            tableView.register(
                SubscriptionSortingCell.nib,
                forCellReuseIdentifier: SubscriptionSortingCell.identifier
            )
        }
    }

    // Start the constraint with negative value (view height + headerView height) so we can
    // animate it later when the view is presented.
    @IBOutlet weak var tableViewViewTopConstraint: NSLayoutConstraint! {
        didSet {
            tableViewViewTopConstraint.constant = viewModel.initialTableViewPosition
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
            instance.tableViewViewTopConstraint.constant = 0

            instance.animates({
                instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                instance.layoutIfNeeded()
            })
        }

        return instance
    }

    // MARK: Hiding the View

    @objc func close() {
        tableViewViewTopConstraint.constant = viewModel.initialTableViewPosition

        animates({
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: {
            self.removeFromSuperview()
        })
    }

    // MARK: IBAction

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        close()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionSortingCell.identifier) as? SubscriptionSortingCell else {
            return UITableViewCell()
        }

        cell.imageViewIcon.image = viewModel.image(for: indexPath)
        cell.labelTitle.text = viewModel.title(for: indexPath)

        if viewModel.isSelected(indexPath: indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let viewHeight = viewModel.listSeparatorHeight
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: viewHeight))
            view.backgroundColor = .white

            let horizontalSpacing = 16.0
            let separator = UIView(frame: CGRect(
                x: horizontalSpacing,
                y: Double(viewHeight) / 2,
                width: Double(tableView.bounds.width) - horizontalSpacing * 2,
                height: 0.5
            ))

            separator.backgroundColor = .RCLightGray()
            view.addSubview(separator)

            return view
        }

        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return viewModel.listSeparatorHeight
        }

        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SubscriptionSortingCell.cellHeight
    }

}

// MARK: UITableViewDelegate

extension SubscriptionsSortingView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.select(indexPath: indexPath)

        if indexPath.section == 0 {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            labelTitle.text = viewModel.sortingTitleDescription
        } else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        delegate?.userDidChangeSortingOptions()
    }

}
