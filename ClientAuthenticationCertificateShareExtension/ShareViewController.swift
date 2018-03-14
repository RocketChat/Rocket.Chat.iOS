//
//  ShareViewController.swift
//  ClientAuthenticationCertificateShareExtension
//
//  Created by inmind IT Solutions on 1/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MobileCoreServices


class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
        var isServerCertificateLoaded = sharedDefaults?.value(forKey: "isServerCertificateLoaded")

        if(isServerCertificateLoaded == nil)
        {
            isServerCertificateLoaded = false
        }

        if(isServerCertificateLoaded as! Bool)
        {
            let alert = UIAlertController(title: "Error", message: "Please logout and restart the app before attempting to load a new certificate. You are currently connected to another server.", preferredStyle: UIAlertControllerStyle.alert)

            let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: .cancel) { action -> Void in
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
            alert.addAction(acceptAction)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            if let content = extensionContext!.inputItems.first as? NSExtensionItem {
                if let contents = content.attachments as? [NSItemProvider] {
                    for attachment in contents {
                        let identifier = kUTTypePKCS12 as String
                        let hasItemConforming =  attachment.hasItemConformingToTypeIdentifier(identifier)
                        print("LOG : \(hasItemConforming)")
                        if hasItemConforming {
                            attachment.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (coding:NSSecureCoding?, error:Error!) in

                                let codObj = coding as! NSURL // swiftlint:disable:this force_cast
                                let PKCS12Data: NSData = NSData(contentsOfFile: codObj.path!)!

                                let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
                                sharedDefaults?.set(PKCS12Data, forKey: "clientCertificate")
                                sharedDefaults?.set(nil, forKey: "certificatePassword")
                                sharedDefaults?.synchronize()

                                let alert = UIAlertController(title: "Success", message: "Client Authentication Certificate loaded successfully.", preferredStyle: UIAlertControllerStyle.alert)
                                let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: .cancel) { action -> Void in
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                }

                                alert.addAction(acceptAction)
                                self.present(alert, animated: true, completion: nil)
                            })
                        }
                    }
                }
            }
        }

    }

}

