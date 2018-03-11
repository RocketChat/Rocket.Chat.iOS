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
            attachment.attachmentsListMap(json, realm: Realm.shared)
            return attachment
        }
    }
}

class FilesListViewController: UIViewController {

    @IBOutlet weak var filesCollctionView: UICollectionView!
    var subscription: Subscription!
    var attachments: [Attachment]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filesCollctionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        self.getConversationMessages()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getConversationMessages() {
        guard let subscription = subscription else { return }
        let request = SubscriptionAttachmentsRequest(roomId: subscription.rid, type: subscription.type)
        API.current()?.fetch(request, succeeded: { result in
            guard let files: [Attachment] = result.getFiles() else { return }
            self.attachments = files
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
        if self.attachments == nil {
            return 0
        } else {
            return self.attachments.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        if self.attachments != nil && self.attachments.count != 0 {
            guard let view = ChatMessageImageView.instantiateFromNib() else { return UICollectionViewCell() }
            view.attachment = self.attachments[indexPath.row]
            cell.addSubview(view)
        }
        return cell
    }
}

extension FilesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 200, height: 200)
    }
}
