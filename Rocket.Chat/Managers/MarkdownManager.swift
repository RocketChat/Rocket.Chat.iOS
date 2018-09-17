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

        parser.defaultAttributes = [NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: defaultFontSize)]
        parser.quoteAttributes = [
            NSAttributedString.Key.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize),
            NSAttributedString.Key.backgroundColor.rawValue: UIColor.codeBackground
        ]
        parser.quoteBlockAttributes = parser.quoteAttributes

        var codeAttributes: [String: Any] = [NSAttributedString.Key.backgroundColor.rawValue: UIColor.codeBackground]
        codeAttributes[NSAttributedString.Key.foregroundColor.rawValue] = UIColor.code
        if let codeFont = UIFont(name: "Courier New", size: defaultFontSize)?.bold() {
            codeAttributes[NSAttributedString.Key.font.rawValue] = codeFont
        }

        parser.inlineCodeAttributes = codeAttributes
        parser.codeAttributes = codeAttributes

        parser.strongAttributes = [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: defaultFontSize)]
        parser.italicAttributes = [NSAttributedString.Key.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize)]
        parser.strikeAttributes = [NSAttributedString.Key.strikethroughStyle.rawValue: NSNumber(value: NSUnderlineStyle.single.rawValue)]
        parser.linkAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.darkGray]

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
            1: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 26)],
            2: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 24)],
            3: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 18)],
            4: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 16)]
        ]
    }

    func transformAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        return parser.attributedStringFromAttributedMarkdownString(attributedString)
    }
}
