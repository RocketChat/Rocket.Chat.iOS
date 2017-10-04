//
//  MessagesListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class MessagesListViewData {
    var subscription: Subscription?
}

class MessagesListViewController: UIViewController {
    var data = MessagesListViewData()

    @IBOutlet weak var collectionView: UICollectionView!
}

extension MessagesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension MessagesListViewController: UICollectionViewDelegate {

}
