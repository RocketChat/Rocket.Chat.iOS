//
//  API.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol APIRequestMiddleware {
    var api: API { get }
    init(api: API)

    func handle<R: APIRequest>(_ request: inout R) -> APIError?
}

protocol APIFetcher {
    @discardableResult
    func fetch<R: APIRequest>(_ request: R, completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask?
    @discardableResult
    func fetch<R: APIRequest>(_ request: R, options: APIRequestOptionSet, completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask?
    @discardableResult
    func fetch<R: APIRequest>(_ request: R, options: APIRequestOptionSet, sessionDelegate: URLSessionTaskDelegate?, completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask?
}

extension APIFetcher {
    @discardableResult
    func fetch<R: APIRequest>(_ request: R, completion: ((APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask? {
        return fetch(request, options: [], sessionDelegate: nil, completion: completion)
    }

    @discardableResult
    func fetch<R: APIRequest>(_ request: R, options: APIRequestOptionSet, completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask? {
        return fetch(request, options: options, sessionDelegate: nil, completion: completion)
    }
}

typealias AnyAPIFetcher = Any & APIFetcher

final class API: APIFetcher {
    let host: URL
    let version: Version

    var requestMiddlewares = [APIRequestMiddleware]()

    var authToken: String?
    var userId: String?
    var language: String?

    static let userAgent: String = {
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let bundleVersion = info?["CFBundleVersion"] as? String ?? "-"
        let systemVersion = UIDevice.current.systemVersion
        return "RC Mobile; iOS \(systemVersion); v\(appVersion) (\(bundleVersion))"
    }()

    convenience init?(host: String, version: Version = .zero) {
        guard let url = URL(string: host)?.httpServerURL() else {
            return nil
        }

        self.init(host: url, version: version)
    }

    init(host: URL, version: Version = .zero) {
        self.host = host
        self.version = version

        requestMiddlewares.append(VersionMiddleware(api: self))
    }

    @discardableResult
    func fetch<R: APIRequest>(_ request: R, options: APIRequestOptionSet = [], sessionDelegate: URLSessionTaskDelegate? = nil,
                              completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask? {
        var transformedRequest = request
        for middleware in requestMiddlewares {
            if let error = middleware.handle(&transformedRequest) {
                completion?(.error(error))
                return nil
            }
        }

        guard let request = transformedRequest.request(for: self, options: options) else {
            completion?(.error(.malformedRequest))
            return nil
        }

        var session: URLSession = URLSession.shared

        if let sessionDelegate = sessionDelegate {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 30

            session = URLSession(
                configuration: configuration,
                delegate: sessionDelegate,
                delegateQueue: nil
            )
        }

        #if DEBUG
        var body = ""

        if let data = transformedRequest.body() {
            body = ": \(String(data: data, encoding: .utf8) ?? "")"
        }

        Log.debug("[REST][REQUEST]: \(request.url?.absoluteString ?? "")\(body)")
        #endif

        let task = session.dataTask(with: request) { (data, _, error) in
            func completeWithResponse(_ response: APIResponse<R.APIResourceType>) {
                switch response {
                case .resource:
                    DispatchQueue.main.async {
                        completion?(response)
                    }
                case .error:
                    if options.retries > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.fetch(
                                transformedRequest,
                                options: options.withRetries(options.retries - 1),
                                sessionDelegate: sessionDelegate,
                                completion: completion
                            )
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion?(response)
                        }
                    }
                }
            }

            if let error = error as NSError? {
                #if DEBUG
                Log.debug("[REST][RESULT][ERROR][\(request.url?.absoluteString ?? "")]: \(error)")
                #endif

                if NSError.sslErrors.contains(error.code) {
                    completeWithResponse(.error(.notSecured))
                } else {
                    completeWithResponse(.error(.error(error)))
                }

                return
            }

            guard let data = data else {
                #if DEBUG
                Log.debug("[REST][RESULT][\(request.url?.absoluteString ?? "")]: No data.")
                #endif

                completion?(.error(.noData))
                return
            }

            let json = try? JSON(data: data)
            completeWithResponse(APIResponse<R.APIResourceType>.resource(R.APIResourceType(raw: json)))

            #if DEBUG
            Log.debug("[REST][RESULT][\(request.url?.absoluteString ?? "")]: \(json?.rawString() ?? "").")
            #endif
        }

        task.resume()

        return task
    }
}
