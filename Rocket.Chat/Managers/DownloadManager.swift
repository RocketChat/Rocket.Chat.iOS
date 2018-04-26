//
//  DownloadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class DownloadManager {

    /**
        - parameters:
            - url: The URL of the file to fetch the name of it.
        - returns: The filename based on the file URL.
     */
    static func filenameFor(_ url: String) -> String? {
        return url.components(separatedBy: "/").last
    }

    /**
        This method will generate an URL on cache repository based
        on the filename parameter.

        - parameters:
            - filename: The filename to generate the URL
        - returns: The local file URL on cache repository.
     */
    static func localFileURLFor(_ filename: String) -> URL? {
        if let docDirectory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return docDirectory.appendingPathComponent(filename)
        }

        return nil
    }

    /**
        This method checks of the file exists on file system.
 
        - parameters:
            - localUrl: The local URL to be searched.
        - returns: Returns if the file exists or not.
     */
    static func fileExists(_ localUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: localUrl.path)
    }

    /**
        This method will download a file from an URL and save it
        on the filesystem, the localUrl parameter, then will call
        the completion block. If file already exists, it will just
        call the completion block.
 
        - parameters:
            - url: The file remote URL to be downloaded.
            - localUrl: The file local URL to be saved.
            - completion: The completion block to be called.
     */
    static func download(url: URL, to localUrl: URL, completion: @escaping () -> Void) {
        // File may already exists
        if fileExists(localUrl) {
            completion()
            return
        }

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)

                    DispatchQueue.main.async {
                        completion()
                    }
                } catch let writeError {
                    print("error writing file \(localUrl) : \(writeError)")

                    DispatchQueue.main.async {
                        completion()
                    }
                }

            } else {
                print("Failure: %@", error?.localizedDescription ?? "")
            }
        }

        task.resume()
    }

}
