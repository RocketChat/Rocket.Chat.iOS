//
//  MarkdownManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RCMarkdownParser

class MarkdownManager {
    static let shared = MarkdownManager()

    static var parser: RCMarkdownParser {
        return shared.parser
    }

    let parser = RCMarkdownParser.standardParser

    init() {
        let defaultFontSize = MessageTextFontAttributes.defaultFontSize

        parser.defaultAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: defaultFontSize)]
        parser.quoteAttributes = [
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: defaultFontSize),
            NSBackgroundColorAttributeName: UIColor.codeBackground
        ]
        parser.quoteBlockAttributes = parser.quoteAttributes

        var codeAttributes: [String: Any] = [NSBackgroundColorAttributeName: UIColor.codeBackground]
        codeAttributes[NSForegroundColorAttributeName] = UIColor.code
        if let codeFont = UIFont(name: "Courier New", size: defaultFontSize)?.bold() {
            codeAttributes[NSFontAttributeName] = codeFont
        }

        parser.inlineCodeAttributes = codeAttributes
        parser.codeAttributes = codeAttributes

        parser.strongAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: defaultFontSize)]
        parser.italicAttributes = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: defaultFontSize)]
        parser.strikeAttributes = [NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)]
        parser.linkAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]

        parser.downloadImage = { urlString, completion in
            guard let url = URL(string: urlString) else { return }
            guard let filename = DownloadManager.filenameFor(urlString) else { return }
            guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

            func image() -> UIImage? {
                if let data = try? Data(contentsOf: localFileURL) {
                    return UIImage(data: data)
                }

                return nil
            }

            if DownloadManager.fileExists(localFileURL) {
                completion?(image())
            } else {
                DownloadManager.download(url: url, to: localFileURL) {
                    DispatchQueue.main.async {
                        completion?(image())
                    }
                }
            }
        }

        parser.headerAttributes = [
            1: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 26)],
            2: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)],
            3: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)],
            4: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        ]
    }
}
