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

        parser.defaultAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: defaultFontSize)]
        parser.quoteAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize),
            NSAttributedStringKey.backgroundColor.rawValue: UIColor.codeBackground
        ]
        parser.quoteBlockAttributes = parser.quoteAttributes

        var codeAttributes: [String: Any] = [NSAttributedStringKey.backgroundColor.rawValue: UIColor.codeBackground]
        codeAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor.code
        if let codeFont = UIFont(name: "Courier New", size: defaultFontSize)?.bold() {
            codeAttributes[NSAttributedStringKey.font.rawValue] = codeFont
        }

        parser.inlineCodeAttributes = codeAttributes
        parser.codeAttributes = codeAttributes

        parser.strongAttributes = [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: defaultFontSize)]
        parser.italicAttributes = [NSAttributedStringKey.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize)]
        parser.strikeAttributes = [NSAttributedStringKey.strikethroughStyle.rawValue: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)]
        parser.linkAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray]

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
            1: [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: 26)],
            2: [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: 24)],
            3: [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: 18)],
            4: [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: 16)]
        ]
    }

    func transformAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        return parser.attributedStringFromAttributedMarkdownString(attributedString)
    }
}
