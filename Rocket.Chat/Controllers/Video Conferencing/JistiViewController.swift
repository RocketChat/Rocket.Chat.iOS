//
//  JitsiViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 21/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import JitsiMeet

final class JitsiViewController: UIViewController {

    let viewModel = JitsiViewModel()

    @IBOutlet weak var jitsiMeetView: JitsiMeetView?

    override func viewDidLoad() {
        super.viewDidLoad()

        jitsiMeetView?.delegate = self
        jitsiMeetView?.loadURLObject([
            "config": [
                "startWithAudioMuted": false,
                "startWithVideoMuted": true
            ],
            "context": [
                "user": [
                    "name": viewModel.userDisplayName,
                    "avatar": viewModel.userAvatar
                ],
                "iss": "rocketchat-ios",
            ],
            "url": viewModel.videoCallURL
        ])
    }

    func close() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil

        dismiss(animated: true, completion: nil)
    }

    // MARK: IBAction

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        close()
    }

}

// MARK: JitsiMeetViewDelegate

extension JitsiViewController: JitsiMeetViewDelegate {

    func onJitsiMeetViewDelegateEvent(name: String, data: [AnyHashable: Any]) {
        print("[\(#file):\(#line)] JitsiMeetViewDelegate \(name) \(data)")
    }

    func conferenceFailed(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_FAILED", data: data)
        print("conference Failed log is : \(data)")
    }

    func conferenceJoined(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_JOINED", data: data)
        print("conference Joined log is : \(data)")
    }

    func conferenceLeft(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data: data)
        print("conference Left log is : \(data)")
        close()
    }

    func conferenceWillJoin(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data: data)
        print("conference Join log is : \(data)")
    }

    func conferenceWillLeave(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_LEAVE", data: data)
        print("conference Leave log is : \(data)")
    }

    func loadConfigError(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data: data)
        print("conference Error log is : \(data)")
    }

}
