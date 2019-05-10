//
//  APISecurity.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 15/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

public struct IdentityAndTrust {
    public var identityRef: SecIdentity
    public var trust: SecTrust
    public var certArray: NSArray
}

// swiftlint:disable force_cast
public func extractIdentity(certificateData: NSData, password: String) -> IdentityAndTrust? {
    var identityAndTrust: IdentityAndTrust?
    var securityError: OSStatus = errSecSuccess

    var items: CFArray?
    let certOptions = [kSecImportExportPassphrase as String: password]

    securityError = SecPKCS12Import(certificateData, certOptions as CFDictionary, &items)

    if securityError == errSecSuccess, let certItems = items {
        let certItemsArray = certItems as Array
        let dict: AnyObject? = certItemsArray.first

        if let certEntry = dict as? [String: AnyObject] {
            let identityPointer: AnyObject? = certEntry["identity"]
            let secIdentityRef: SecIdentity = identityPointer as! SecIdentity

            let trustPointer: AnyObject? = certEntry["trust"]
            let trustRef: SecTrust = trustPointer as! SecTrust

            var certRef: SecCertificate!
            SecIdentityCopyCertificate(secIdentityRef, &certRef)

            let certArray = NSMutableArray()
            certArray.add(certRef as SecCertificate)

            identityAndTrust = IdentityAndTrust(
                identityRef: secIdentityRef,
                trust: trustRef,
                certArray: certArray
            )
        }
    }

    return identityAndTrust
}

final class TwoWaySessionDelegate: NSObject, URLSessionDelegate {

    var sslCertificatePath: URL
    var sslCertificatePassword: String

    init(certificatePath: URL, password: String) {
        self.sslCertificatePath = certificatePath
        self.sslCertificatePassword = password
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard
            let data = try? Data(contentsOf: sslCertificatePath) as NSData,
            let identityAndTrust = extractIdentity(certificateData: data, password: sslCertificatePassword)
        else {
            challenge.sender?.cancel(challenge)
            completionHandler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
            return
        }

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            let urlCredential: URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as [AnyObject],
                persistence: URLCredential.Persistence.forSession
            )

            completionHandler(URLSession.AuthChallengeDisposition.useCredential, urlCredential)
            return
        }

        challenge.sender?.cancel(challenge)
        completionHandler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
    }

}
