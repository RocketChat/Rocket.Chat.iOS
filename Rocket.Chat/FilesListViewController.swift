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
    func getFiles() -> [Attachment]? {
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
    var attchments: [Attachment]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filesCollctionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
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
            guard let files: [Attachment] = result.getFiles() else { return }
            self.attchments = files
            DispatchQueue.main.async {
                self.filesCollctionView.reloadData()
            }
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
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        if self.attchments != nil && self.attchments.count != 0 {
            guard let view = ChatMessageImageView.instantiateFromNib() else { return UICollectionViewCell() }
            view.attachment = self.attchments[indexPath.row]
            cell.addSubview(view)
        }
        return cell
    }
}
