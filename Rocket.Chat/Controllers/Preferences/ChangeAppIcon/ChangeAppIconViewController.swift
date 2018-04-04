//
//  ChangeAppIconViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 08.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChangeAppIconViewController: UIViewController {

    private let viewModel = ChangeAppIconViewModel()

    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title

        collectionView?.register(
            ReusableViewText.nib,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: ReusableViewText.identifier
        )
    }

    private func changeIcon(name: String) {
        let iconName = name == "Default" ? nil : name

        if #available(iOS 10.3, *) {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    self.reportError(message: (error as NSError).localizedDescription)
                }

                self.collectionView.reloadData()
            }
        } else {
            reportError(message: viewModel.iosVersionMessage)
        }
    }

    private func reportError(message: String?) {
        guard let message = message else {
            return
        }

        alert(title: viewModel.errorTitle, message: message, handler: nil)
    }

}

extension ChangeAppIconViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.availableIcons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: viewModel.cellIdentifier,
            for: indexPath
        ) as? ChangeAppIconCell else {
            fatalError("Could not dequeue reuable cell as ChangeAppIconCell")
        }

        let iconName = viewModel.availableIcons[indexPath.row]

        var isSelected = false
        if #available(iOS 10.3, *) {
            if let selectedIcon = UIApplication.shared.alternateIconName {
                isSelected = iconName == selectedIcon
            } else {
                isSelected = indexPath.row == 0
            }
        }

        cell.setIcon(name: iconName, selected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableViewText.identifier, for: indexPath) as? ReusableViewText {
                view.labelText.text = viewModel.header
                return view
            }
        }

        return UICollectionReusableView()
    }

}

extension ChangeAppIconViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 120)
        }

        return CGSize(width: 0, height: 0)
    }

}

extension ChangeAppIconViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeIcon(name: viewModel.availableIcons[indexPath.row])
    }

}
