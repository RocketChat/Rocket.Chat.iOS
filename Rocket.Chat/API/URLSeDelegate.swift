//
//  URLSeDelegate.swift
//  Rocket.Chat
//
//  Created by inmind IT Solutions on 1/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class URLSeDelegate: NSObject, URLSessionDelegate {
    static let shared = URLSeDelegate.init()
    private override init() {}
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition,
        URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod
            == (NSURLAuthenticationMethodServerTrust) {
            let identityAndTrust: IdentityAndTrust = self.extractIdentity()
            if(identityAndTrust.identityRef == nil)
            {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            else
            {
                let urlCredential: URLCredential = URLCredential(
                    identity: identityAndTrust.identityRef!,
                    certificates: identityAndTrust.certArray as? [AnyObject],
                    persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, urlCredential)
            }
        }
        else if challenge.protectionSpace.authenticationMethod
            == NSURLAuthenticationMethodClientCertificate {
            let identityAndTrust: IdentityAndTrust = self.extractIdentity()
            let urlCredential: URLCredential = URLCredential(
                identity: identityAndTrust.identityRef!,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession)
            completionHandler(.useCredential, urlCredential)
        }
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust: IdentityAndTrust!
        var securityError: OSStatus = errSecSuccess

        let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
        let PKCS12Data = sharedDefaults?.value(forKey: "clientCertificate")

        if(PKCS12Data != nil)
        {
            let key : NSString = kSecImportExportPassphrase as NSString
            let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
            let password = sharedDefaults?.value(forKey: "certificatePassword")

            let options : NSDictionary = [key: password]

            var items: CFArray?

            securityError = SecPKCS12Import(PKCS12Data as! CFData, options, &items) // swiftlint:disable:this force_cast

            if securityError == errSecSuccess {
                let certItems: CFArray = items as CFArray!
                let certItemsArray: Array = certItems as Array
                let dict: AnyObject? = certItemsArray.first
                if let certEntry: Dictionary = dict as? Dictionary<String, AnyObject> {
                    // grab the identity
                    let identityPointer: AnyObject? = certEntry["identity"]
                    let secIdentityRef: SecIdentity = identityPointer as! SecIdentity! // swiftlint:disable:this force_cast
                    // grab the trust
                    let trustPointer: AnyObject? = certEntry["trust"]
                    let trustRef: SecTrust = trustPointer as! SecTrust // swiftlint:disable:this force_cast
                    // grab the certe
                    let chainPointer: AnyObject? = certEntry["chain"]
                    identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                        trust: trustRef, certArray: chainPointer!)
                }
            }
            else
            {
                let key : NSString = kSecImportExportPassphrase as NSString
                let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
                sharedDefaults?.removeObject(forKey: "certificatePassword")
                sharedDefaults?.synchronize()

                return IdentityAndTrust(identityRef: nil,
                                        trust: nil, certArray: nil)
            }
        }
        else
        {
            return IdentityAndTrust(identityRef: nil,
                                    trust: nil, certArray: nil)
        }
        return identityAndTrust
    }
}

struct IdentityAndTrust {
    var identityRef: SecIdentity?
    var trust: SecTrust?
    var certArray: AnyObject?
}
