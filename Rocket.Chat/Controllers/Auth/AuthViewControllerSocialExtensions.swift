//
//  AuthViewControllerSocialExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 04/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import GoogleSignIn
import FBSDKLoginKit

// MARK: Facebook

extension AuthViewController {
    func authenticateWithFacebook() {
        startLoading()
        facebookLoginManager.logIn(withReadPermissions: [], from: self, handler: self.facebookSignIn)
    }

    func facebookSignIn(result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard
            error == nil,
            let token = FBSDKAccessToken.current(),
            let accessToken = token.tokenString,
            let idToken = token.userID,
            let expirationDate = token.expirationDate
        else {
            stopLoading()
            return
        }

        let params = [
            "serviceName": "facebook",
            "accessToken": accessToken,
            "idToken": idToken,
            "expiresIn": Int(expirationDate.timeIntervalSinceNow),
            "scope": "profile"
        ] as [String: Any]

        AuthManager.auth(params: params, completion: self.handleAuthenticationResponse)
    }
}

// MARK: Google

extension AuthViewController {
    func authenticateWithGoogle() {
        startLoading()

        GIDSignIn.sharedInstance().clientID = "662030055877-9qc3lqsbgif4k1ktl89dqeaec3m163i4.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}

extension AuthViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            stopLoading()
            return
        }

        let params = [
            "serviceName": "google",
            "accessToken": user.authentication.accessToken,
            "refreshToken": user.authentication.refreshToken,
            "idToken": user.authentication.idToken,
            "expiresIn": Int(user.authentication.accessTokenExpirationDate.timeIntervalSinceNow),
            "scope": "profile"
        ] as [String: Any]

        AuthManager.auth(params: params, completion: self.handleAuthenticationResponse)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        stopLoading()
    }
}

extension AuthViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if error != nil {
            stopLoading()
        } else {
            startLoading()
        }
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        startLoading()
        present(viewController, animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
}
