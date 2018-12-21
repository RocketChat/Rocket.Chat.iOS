//
//  JistiViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 21/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import JitsiMeet

final class JistiViewController: UIViewController {

    @IBOutlet weak var jistiMeetView: JitsiMeetView?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let defaults = UserDefaults.standard
//        defaults.setValue("1", forKey: "isVideoGoing")
//
//        if(UserDefaults.standard.value(forKey: "serverurl1") != nil)
//        {
//
//            if(UserDefaults.standard.value(forKey: "isTapped") != nil){
//
//                let serverUrlVideoVC : String = (defaults.object(forKey:"serverurl1") as? String)!
//                //    let calll : String = "org.jitsi.meet:" + serverUrlVideoVC
//
//                let objJitsiMeetView: JitsiMeetView  = self.myJitsiMeetView
//                objJitsiMeetView.delegate = self as! JitsiMeetViewDelegate
//
//                self.myName1.text = (defaults.value(forKey: "bodyTitle") as? String)!
//                DispatchQueue.main.async {
//                    objJitsiMeetView.loadURLString(serverUrlVideoVC as? String)
//                    //                objJitsiMeetView.loadURLObject(["config": ["startWithAudioMuted": false, "startWithVideoMuted": true], "url": serverUrlVideoVC])
//                }
//
//                objJitsiMeetView.accessibilityActivate()
//
//
//
//
//            }
//
//        }
//        else
//        {
//            let serverUrlVideoVC : String = (defaults.object(forKey:"serverurl") as? String)!
//            print("ServerUrlVideoVC is : \(String(describing: serverUrlVideoVC))")
//            //   let objJitsiMeetView: JitsiMeetView  = (self.view as? JitsiMeetView)!
//            let objJitsiMeetView: JitsiMeetView  = self.myJitsiMeetView
//            objJitsiMeetView.delegate = self as! JitsiMeetViewDelegate
//
//            if(defaults.value(forKey: "title") != nil){
//                self.myName1.text = (defaults.value(forKey: "title") as? String)!
//            }
//
//            // objJitsiMeetView.welcomePageEnabled = false
//            DispatchQueue.main.async {
//
//                objJitsiMeetView.loadURLString(serverUrlVideoVC as? String)
//                //                objJitsiMeetView.loadURLObject(["config": ["startWithAudioMuted": false, "startWithVideoMuted": true], "url": serverUrlVideoVC])
//            }
//
//            objJitsiMeetView.accessibilityActivate()
//            defaults.removeObject(forKey: "title")
//        }
//
//
    }

}

// MARK: JitsiMeetViewDelegate

extension JistiViewController: JitsiMeetViewDelegate {

    func onJitsiMeetViewDelegateEvent(name: String, data: [AnyHashable: Any]) {
        print("[\(#file):\(#line)] JitsiMeetViewDelegate \(name) \(data)")
        print("event")
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
        print("call navigation")
        DispatchQueue.main.async {
            if(UserDefaults.standard.value(forKey: "serverurl1") != nil){
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
                self.navigationController?.isNavigationBarHidden = false
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "serverurl1")
                defaults.removeObject(forKey: "isTapped")
                defaults.removeObject(forKey: "bodyTitle")
            }
            else {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popViewController(animated: true)
                //  self.navigationController?.setNavigationBarHidden(false, animated: animated)
            }
            let defaults = UserDefaults.standard
            defaults.setValue("0", forKey: "isVideoGoing")
        }
    }

    func conferenceWillJoin(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data: data)
        print("conference Join log is : \(data)")
    }

    func conferenceWillLeave(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_LEAVE", data: data)
        print("conference Leave log is : \(data)")
        print("call navigation")
        DispatchQueue.main.async {
            if(UserDefaults.standard.value(forKey: "serverurl1") != nil){
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
                self.navigationController?.isNavigationBarHidden = false
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "serverurl1")
                defaults.removeObject(forKey: "isTapped")
                defaults.removeObject(forKey: "bodyTitle")

                defaults.setValue("0", forKey: "isVideoGoing")
            }
            else {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popViewController(animated: true)
                //  self.navigationController?.setNavigationBarHidden(false, animated: animated)
            }
        }
        print("navigation called")

    }

    func loadConfigError(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data: data)
        print("conference Error log is : \(data)")
    }

}
