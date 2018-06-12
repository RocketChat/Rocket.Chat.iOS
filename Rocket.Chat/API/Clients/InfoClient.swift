//
//  InfoClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct InfoClient: APIClient {
    let api: AnyAPIFetcher

    func fetchInfo(realm: Realm? = Realm.current, completion: VoidCompletion? = nil) {
        api.fetch(InfoRequest()) { response in
            switch response {
            case .resource(let resource):
                guard let version = resource.version else { return }
                realm?.execute({ realm in
                    AuthManager.isAuthenticated(realm: realm)?.serverVersion = version
                }, completion: completion)
            case .error:
                break
            }
        }
    }

    func fetchLoginServices(realm: Realm? = Realm.current, completion: ((_ loginServices: [LoginService], _ shouldRetrieveLoginServices: Bool) -> Void)? = nil) {
        api.fetch(LoginServicesRequest()) { response in
            switch response {
            case .resource(let res):
                completion?(res.loginServices, false)
                realm?.execute({ realm in
                    realm.add(res.loginServices, update: true)
                })
            case .error(let error):
                switch error {
                case .version:
                    // version fallback
                    LoginServiceManager.subscribe()
                    completion?([LoginService](), true)
                default:
                    break
                }
            }

        }
    }

    func fetchPermissions(realm: Realm? = Realm.current) {
        api.fetch(PermissionsRequest()) { response in
            switch response {
            case .resource(let res):
                realm?.execute({ realm in
                    realm.add(res.permissions, update: true)
                })
            case .error(let error):
                switch error {
                case .version:
                    // version fallback
                    PermissionManager.updatePermissions()
                default:
                    break
                }
            }

        }
    }
}
