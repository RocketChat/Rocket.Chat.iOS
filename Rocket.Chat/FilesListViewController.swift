//
//  FilesListViewController.swift
//  Rocket.Chat
//
//  Created by Macbook Home on 03.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension APIResult where T == SubscriptionAttachmentsRequest {
    func getFiles() -> [Attachment?]? {
        return raw?["files"].arrayValue.map { json in
            let attachment = Attachment()
            attachment.map(json, realm: Realm.shared)
            return attachment
        }
    }
}

class FilesListViewController: UIViewController {

    @IBOutlet weak var filesCollctionView: UICollectionView!
    var subscription: Subscription!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGroupMessages()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getGroupMessages() {
        guard let subscription = subscription else { return }
        let request = SubscriptionAttachmentsRequest(roomName: subscription.name, type: subscription.type)
        API.current()?.fetch(request, succeeded: { result in
            guard let files: Array = result.getFiles() else { return }
        }, errored: nil)
    }
}

extension FilesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Do nothing
    }
}

extension FilesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return UICollectionViewCell()
    }
}
