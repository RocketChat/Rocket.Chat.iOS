//
//  MarkdownManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RCMarkdownParser

struct MarkdownColorAttributes {
    let quoteBackgroundColor: UIColor
    let codeBackgroundColor: UIColor
    let codeTextColor: UIColor
    let linkColor: UIColor
}

class MarkdownManager {
    static let shared = MarkdownManager()

    lazy var defaultParser = RCMarkdownParser()

    lazy var lightParser: RCMarkdownParser = {
        let parser = RCMarkdownParser()
        parser.useColorAttributes(colorAttributes(for: .light))
        return parser
    }()

    lazy var darkParser: RCMarkdownParser = {
        let parser = RCMarkdownParser()
        parser.useColorAttributes(colorAttributes(for: .dark))
        return parser
    }()

    lazy var blackParser: RCMarkdownParser = {
        let parser = RCMarkdownParser()
        parser.useColorAttributes(colorAttributes(for: .black))
        return parser
    }()

    func colorAttributes(for theme: Theme) -> MarkdownColorAttributes {
        return MarkdownColorAttributes(
            quoteBackgroundColor: theme.bannerBackground,
            codeBackgroundColor: theme.bannerBackground,
            codeTextColor: theme.controlText,
            linkColor: theme.hyperlink
        )
    }

    func transformAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        return defaultParser.attributedStringFromAttributedMarkdownString(attributedString)
    }

    func transformAttributedString(_ attributedString: NSAttributedString, with theme: Theme?) -> NSAttributedString {
        guard let theme = theme else { return defaultParser.attributedStringFromAttributedMarkdownString(attributedString) }

        switch theme {
        case .light: return lightParser.attributedStringFromAttributedMarkdownString(attributedString)
        case .dark: return darkParser.attributedStringFromAttributedMarkdownString(attributedString)
        case .black: return blackParser.attributedStringFromAttributedMarkdownString(attributedString)
        default: return defaultParser.attributedStringFromAttributedMarkdownString(attributedString)
        }
    }
}

fileprivate extension RCMarkdownParser {
    func useColorAttributes(_ attributes: MarkdownColorAttributes) {
        let defaultFontSize = MessageTextFontAttributes.defaultFontSize

        let quoteAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize),
            NSAttributedStringKey.backgroundColor.rawValue: attributes.quoteBackgroundColor
        ]

        var codeAttributes: [String: Any] = [NSAttributedStringKey.backgroundColor.rawValue: attributes.codeBackgroundColor]
        codeAttributes[NSAttributedStringKey.foregroundColor.rawValue] = attributes.codeTextColor
        if let codeFont = UIFont(name: "Courier New", size: defaultFontSize)?.bold() {
            codeAttributes[NSAttributedStringKey.font.rawValue] = codeFont
        }

        let linkAttributes = [NSAttributedStringKey.foregroundColor.rawValue: attributes.linkColor]

        self.quoteAttributes = quoteAttributes
        self.quoteBlockAttributes = quoteAttributes
        self.inlineCodeAttributes = codeAttributes
        self.codeAttributes = codeAttributes
        self.linkAttributes = linkAttributes
    }

    static func initWithDefaultAttributes() -> RCMarkdownParser {
        let parser = RCMarkdownParser()

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

        return parser
    }
}
