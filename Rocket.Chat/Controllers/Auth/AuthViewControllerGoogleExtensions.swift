//
//  AuthViewControllerGoogleExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 04/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

extension AuthViewController {
    func authenticateWithGoogle() {
        startLoading()

        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
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
        ] as [String : Any]

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
