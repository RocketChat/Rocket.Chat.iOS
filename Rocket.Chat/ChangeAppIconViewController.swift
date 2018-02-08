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

    @IBOutlet weak var labelHeaderTitle: UILabel! {
        didSet {
            labelHeaderTitle.text = viewModel.header
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func changeIcon(name: String) {
        let iconName = name == "Default" ? nil : name

        if #available(iOS 10.3, *) {
            UIApplication.shared.setAlternateIconName(iconName) { error in

                guard let error = error else {
                    return
                }

                self.reportError(message: (error as NSError).localizedDescription)

            }
        } else {
            reportError(message: "Alternate application icons are not supported on iOS version below 10.3")
        }
    }

    private func reportError(message: String?) {
        let alert = UIAlertController(title: "Cannot Change Icon",
                                      message: message,
                                      preferredStyle: .alert)

        let done = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(done)

        present(alert, animated: true)
    }

}

extension ChangeAppIconViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.availableIcons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier, for: indexPath) as? ChangeAppIconCell else {
            fatalError("Could not dequeue reuable cell as ChangeAppIconCell")
        }

        cell.setIcon(name: viewModel.availableIcons[indexPath.row])

        return cell
    }
}

extension ChangeAppIconViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeIcon(name: viewModel.availableIcons[indexPath.row])
    }
}
