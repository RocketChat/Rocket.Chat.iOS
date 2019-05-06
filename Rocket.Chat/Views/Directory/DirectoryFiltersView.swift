//
//  DirectoryFiltersView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

let kDirectoryFilterViewWorkspaceLocalKey = "kDirectoryFilterViewWorkspaceLocalKey"

protocol DirectoryFiltersViewDelegate: class {
    func userDidChangeFilterOption(selected: DirectoryRequestType)
}

final class DirectoryFiltersView: UIView {

    let viewModel = DirectoryFiltersViewModel()

    weak var delegate: DirectoryFiltersViewDelegate?

    @IBOutlet weak var tappableView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            tappableView.addGestureRecognizer(tapGesture)
        }
    }

    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = viewModel.searchBy
        }
    }

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var filterImageView: UIImageView! {
        didSet {
            filterImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 + Double.pi))
        }
    }

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var separatorViewFederation: UIView!
    @IBOutlet weak var switchWorkspace: UISwitch! {
        didSet {
            if UserDefaults.standard.bool(forKey: kDirectoryFilterViewWorkspaceLocalKey) {
                switchWorkspace.isOn = false
            } else {
                switchWorkspace.isOn = true
            }
        }
    }

    @IBOutlet weak var buttonChannels: UIButton! {
        didSet {
            buttonChannels.setTitle(viewModel.channels, for: .normal)
        }
    }

    @IBOutlet weak var buttonUsers: UIButton! {
        didSet {
            buttonUsers.setTitle(viewModel.users, for: .normal)
        }
    }

    @IBOutlet weak var labelFederationTitle: UILabel! {
        didSet {
            labelFederationTitle.text = viewModel.federationTitle
        }
    }

    @IBOutlet weak var labelFederationSubtitle: UILabel! {
        didSet {
            labelFederationSubtitle.text = viewModel.federationSubtitle
        }
    }

    // Start the constraint with negative value (view height + headerView height) so we can
    // animate it later when the view is presented.
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint! {
        didSet {
            viewTopConstraint.constant = viewModel.initialViewPosition
        }
    }

    private func animates(_ animations: @escaping VoidCompletion, completion: VoidCompletion? = nil) {
        UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: {
            animations()
        }, completion: { finished in
            if finished {
                completion?()
            }
        })
    }

    // MARK: Showing the View

    static func showIn(_ view: UIView) -> DirectoryFiltersView? {
        guard let instance = DirectoryFiltersView.instantiateFromNib() else { return nil }
        instance.backgroundColor = UIColor.black.withAlphaComponent(0)
        instance.frame = view.bounds
        view.addSubview(instance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            instance.viewTopConstraint.constant = 0

            instance.animates({
                instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                instance.layoutIfNeeded()
            })
        }

        instance.applyTheme()
        return instance
    }

    // MARK: Hiding the View

    @objc func close() {
        viewTopConstraint.constant = viewModel.initialViewPosition

        animates({
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: {
            self.removeFromSuperview()
        })
    }

    // MARK: IBAction

    @IBAction func recognizeHeaderTapGesture(_ sender: UITapGestureRecognizer) {
        close()
    }

    @IBAction func switchWorkspaceDidChange(_ sender: Any) {
        UserDefaults.standard.set(
            !switchWorkspace.isOn,
            forKey: kDirectoryFilterViewWorkspaceLocalKey
        )

        delegate?.userDidChangeFilterOption(selected: .users)
    }

    @IBAction func buttonFilterChannelDidPressed(_ sender: Any) {
        delegate?.userDidChangeFilterOption(selected: .channels)
        close()
    }

    @IBAction func buttonFilterUserDidPressed(_ sender: Any) {
        delegate?.userDidChangeFilterOption(selected: .users)
        close()
    }

}

// MARK: Themeable

extension DirectoryFiltersView {
    override var theme: Theme? {
        guard let theme = super.theme else { return nil }

        return Theme(
            backgroundColor: theme.appearence == .light ? theme.backgroundColor : theme.focusedBackground,
            focusedBackground: theme.focusedBackground,
            chatComponentBackground: theme.chatComponentBackground,
            auxiliaryBackground: theme.auxiliaryBackground,
            bannerBackground: theme.bannerBackground,
            titleText: theme.titleText,
            bodyText: theme.bodyText,
            borderColor: theme.borderColor,
            controlText: theme.controlText,
            auxiliaryText: theme.auxiliaryText,
            tintColor: theme.tintColor,
            auxiliaryTintColor: theme.auxiliaryTintColor,
            actionTintColor: theme.actionTintColor,
            actionBackgroundColor: theme.actionBackgroundColor,
            mutedAccent: theme.mutedAccent,
            strongAccent: theme.strongAccent,
            appearence: theme.appearence
        )
    }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        labelTitle.textColor = theme.auxiliaryText
        filterImageView.tintColor = theme.auxiliaryText
        separatorView.backgroundColor = theme.mutedAccent

        labelFederationTitle.textColor = theme.bodyText
        labelFederationSubtitle.textColor = theme.auxiliaryText

        let buttonChannelsImage = buttonChannels.image(for: .normal)?.imageWithTint(theme.controlText)
        buttonChannels.setImage(buttonChannelsImage, for: .normal)
        buttonChannels.setTitleColor(theme.controlText, for: .normal)

        let buttonUsersImage = buttonUsers.image(for: .normal)?.imageWithTint(theme.controlText)
        buttonUsers.setImage(buttonUsersImage, for: .normal)
        buttonUsers.setTitleColor(theme.controlText, for: .normal)
    }
}
