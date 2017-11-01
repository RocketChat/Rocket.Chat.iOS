//
//  URLSeDelegate.swift
//  Rocket.Chat
//
//  Created by Bruce on 2017/10/18.
//  Copyright © 2017年 Rocket.Chat. All rights reserved.
//

import UIKit

class URLSeDelegate: NSObject, URLSessionDelegate {
    static let shared = URLSeDelegate.init()
    private override init() {}
    // 在访问资源的时候，如果服务器返回需要授权(提供一个URLCredential对象)
    // 那么该方法就回被调用（这个是URLSessionDelegate代理方法）
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition,
        URLCredential?) -> Void) {
        //认证服务器证书
        if challenge.protectionSpace.authenticationMethod
            == (NSURLAuthenticationMethodServerTrust) {
            print("服务端证书认证！")
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
            let remoteCertificateData
                = CFBridgingRetain(SecCertificateCopyData(certificate))!
            
//            let cerPath = Bundle.main.path(forResource: "tomcat", ofType: "cer")!
            // 获取服务端站点证书
            let fileManager:FileManager = FileManager.default
            let enumer = fileManager.enumerator(atPath: "\(NSHomeDirectory())/Documents/")
            var trustCertPath:String?;
            while true {
                trustCertPath = enumer?.nextObject() as? String
                if trustCertPath != nil {
                    if (trustCertPath?.hasSuffix(".cer"))! {
                        let path = "\(NSHomeDirectory())/Documents/" + trustCertPath!
                        
                        let cerUrl = URL(fileURLWithPath: path)
                        let localCertificateData = try? Data.init(contentsOf: cerUrl)
                        
                        if remoteCertificateData.isEqual(localCertificateData) == true {
                            let credential = URLCredential(trust: serverTrust)
                            challenge.sender?.use(credential, for: challenge)
                            completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                                              URLCredential(trust: challenge.protectionSpace.serverTrust!))
                        } else {
                            completionHandler(.cancelAuthenticationChallenge, nil)
                        }
                        break
                    }
                }
            }
            
        }
            //认证客户端证书
        else if challenge.protectionSpace.authenticationMethod
            == NSURLAuthenticationMethodClientCertificate {
            print("客户端证书认证！")
            //获取客户端证书相关信息
            let identityAndTrust: IdentityAndTrust = self.extractIdentity()
            
            let urlCredential: URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession)

            completionHandler(.useCredential, urlCredential)
        }
            // 其它情况（不接受认证）
        else {
            print("其它情况（不接受认证）")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    //获取客户端证书相关信息
    func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust: IdentityAndTrust!
        var securityError: OSStatus = errSecSuccess

        //读取文件
        var prePath:String?
        let fileManager:FileManager = FileManager.default
        let enumer = fileManager.enumerator(atPath: "\(NSHomeDirectory())/Documents/")
        while true {
            prePath = enumer?.nextObject() as? String
            if prePath != nil {
                if (prePath?.hasSuffix(".px12"))! {
//                    let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
                    let path: String = "\(NSHomeDirectory())/Documents/" + prePath!
                    let PKCS12Data = NSData(contentsOfFile: path)!
                    let key: NSString = kSecImportExportPassphrase as NSString
                    let options: NSDictionary = [key: "123456"] //客户端证书密码

                    var items: CFArray?

                    securityError = SecPKCS12Import(PKCS12Data, options, &items)

                    if securityError == errSecSuccess {
                        let certItems: CFArray = items as CFArray!
                        let certItemsArray: Array = certItems as Array
                        let dict: AnyObject? = certItemsArray.first
                        if let certEntry: Dictionary = dict as? Dictionary<String, AnyObject> {
                            // grab the identity
                            let identityPointer: AnyObject? = certEntry["identity"]
                            let secIdentityRef: SecIdentity = identityPointer as! SecIdentity!

                            // grab the trust
                            let trustPointer: AnyObject? = certEntry["trust"]
                            let trustRef: SecTrust = trustPointer as! SecTrust

                            // grab the cert
                            let chainPointer: AnyObject? = certEntry["chain"]
                            identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                                trust: trustRef, certArray: chainPointer!)
                        }
                    }
                    break
                }
            } else {
                break
            }
        }

        return identityAndTrust
    }
}

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef: SecIdentity
    var trust: SecTrust
    var certArray: AnyObject
}
