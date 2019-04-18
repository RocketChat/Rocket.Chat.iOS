//
//  InterfaceController.swift
//  Rocket.Chat.Watch Extension
//
//  Created by ahmed on 4/12/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var avatarInterfaceImage: WKInterfaceImage!
    @IBOutlet weak var channelsLabel : WKInterfaceLabel!
    @IBOutlet weak var channelsTable: WKInterfaceTable!
    @IBOutlet weak var directMessagesLabel : WKInterfaceLabel!
    @IBOutlet weak var dmTable: WKInterfaceTable!
    struct CellIdentifiers {
        static let channelCell = "channelcell"
        static let dmCell = "directmessagecell"
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        channelsTable.setHidden(true)
        channelsLabel.setHidden(true)
        dmTable.setHidden(true)
        directMessagesLabel.setHidden(true)
        // Check for Watch Connectivity support
        if WCSession.isSupported() {
            let wcsession = WCSession.default
            wcsession.delegate = self
            wcsession.activate()
        }
    }
    // MARK:-  Watch Conenctivity
    func session(_ session: WCSession, didReceiveMessage message: [String:Any]) {
        print(message)
        let username = String(describing: message["username"] as? String ?? "Failed")
        let identifier = String(describing: message["identifier"] as? String ?? "")
        let avatarUrl = String(describing: message["avatarUrl"] as? String ?? "")
        let authToken = avatarUrl.components(separatedBy: "rc_token=")[1].components(separatedBy: ",")[0]
        let serverName = avatarUrl.components(separatedBy: "//")[1].components(separatedBy: "/")[0]
        
        
        Request.getChannels(authToken: authToken, userID: identifier, serverName: serverName) { (success, data) in
            if !success {
                return
            }
            
            guard let channelNames = data else { return }
            self.channelsTable.setHidden(false)
            self.channelsLabel.setHidden(false)
            DispatchQueue.main.async {
                self.channelsTable.setNumberOfRows(channelNames.count, withRowType: CellIdentifiers.channelCell)
                for (index, name) in channelNames.enumerated() {
                    guard let row = self.channelsTable.rowController(at: index) as? ChannelsTableCell else { return }
                    row.channelNameLabel.setText(name)
                }
            }
        }
        Request.getDirectMessages(authToken: authToken, userID: identifier, serverName: serverName) {(success, data) in
            if !success {
                return
            }
            guard let dmNames = data else { return }

            self.dmTable.setHidden(false)
            self.directMessagesLabel.setHidden(false)
            
            DispatchQueue.main.async {
                self.dmTable.setNumberOfRows(dmNames.count, withRowType: CellIdentifiers.dmCell)
                for (index, name) in dmNames.enumerated() {
                    guard let row = self.dmTable.rowController(at: index) as? DirectMessagesTableCell else { return }
                    row.nameLabel.setText(name)
                }
            }
        }
            
        label.setText(username)
        let avatar = URL(string: avatarUrl)
        avatarInterfaceImage.loadImage(url: avatar!)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("---Can Communicate")
        }
    }
}
extension WKInterfaceImage {
    func loadImage(url: URL) -> URLSessionDownloadTask{
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url){ [weak self] url,response,error in
            if error == nil,let url = url, let data = try? Data(contentsOf: url),let image = UIImage(data: data){
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        strongSelf.setImage(image)
                    }
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
