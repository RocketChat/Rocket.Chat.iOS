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

    init(from theme: Theme) {
        quoteBackgroundColor = theme.bannerBackground
        codeBackgroundColor = theme.bannerBackground
        codeTextColor = theme.controlText
        linkColor = theme.actionTintColor
    }
}

class MarkdownManager {
    static let shared = MarkdownManager()

    lazy var defaultParser = RCMarkdownParser.initWithDefaultAttributes()

    lazy var lightParser: RCMarkdownParser = {
        let parser = RCMarkdownParser.initWithDefaultAttributes()
        parser.useColorAttributes(MarkdownColorAttributes(from: .light))
        return parser
    }()

    lazy var darkParser: RCMarkdownParser = {
        let parser = RCMarkdownParser.initWithDefaultAttributes()
        parser.useColorAttributes(MarkdownColorAttributes(from: .dark))
        return parser
    }()

    lazy var blackParser: RCMarkdownParser = {
        let parser = RCMarkdownParser.initWithDefaultAttributes()
        parser.useColorAttributes(MarkdownColorAttributes(from: .black))
        return parser
    }()

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
        let quoteAttributes = [
            NSAttributedString.Key.font.rawValue: MessageTextFontAttributes.italicFont,
            NSAttributedString.Key.backgroundColor.rawValue: attributes.quoteBackgroundColor
        ]

        var codeAttributes: [String: Any] = [NSAttributedString.Key.backgroundColor.rawValue: attributes.codeBackgroundColor]
        codeAttributes[NSAttributedString.Key.foregroundColor.rawValue] = attributes.codeTextColor
        codeAttributes[NSAttributedString.Key.font.rawValue] = MessageTextFontAttributes.monoSpacedFont

        let linkAttributes = [NSAttributedString.Key.foregroundColor.rawValue: attributes.linkColor]

        self.quoteAttributes = quoteAttributes
        self.quoteBlockAttributes = quoteAttributes
        self.inlineCodeAttributes = codeAttributes
        self.codeAttributes = codeAttributes
        self.linkAttributes = linkAttributes
    }

    static func initWithDefaultAttributes() -> RCMarkdownParser {
        let parser = RCMarkdownParser()

        parser.defaultAttributes = [NSAttributedString.Key.font.rawValue: MessageTextFontAttributes.defaultFont]
        parser.quoteAttributes = [
            NSAttributedString.Key.font.rawValue: MessageTextFontAttributes.italicFont,
            NSAttributedString.Key.backgroundColor.rawValue: UIColor.codeBackground
        ]
        parser.quoteBlockAttributes = parser.quoteAttributes

        var codeAttributes: [String: Any] = [NSAttributedString.Key.backgroundColor.rawValue: UIColor.codeBackground]
        codeAttributes[NSAttributedString.Key.foregroundColor.rawValue] = UIColor.code
        codeAttributes[NSAttributedString.Key.font.rawValue] = MessageTextFontAttributes.monoSpacedFont

        parser.inlineCodeAttributes = codeAttributes
        parser.codeAttributes = codeAttributes

        parser.strongAttributes = [NSAttributedString.Key.font.rawValue: MessageTextFontAttributes.boldFont]
        parser.italicAttributes = [NSAttributedString.Key.font.rawValue: MessageTextFontAttributes.italicFont]
        parser.strikeAttributes = [NSAttributedString.Key.strikethroughStyle.rawValue: NSNumber(value: NSUnderlineStyle.single.rawValue)]
        parser.linkAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.darkGray]

        #if !ROCKETCHAT_EXCLUDE_MARKDOWN_DOWNLOAD_MEDIA
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
        #endif

        parser.headerAttributes = [
            1: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 26)],
            2: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 24)],
            3: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 18)],
            4: [NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 16)]
        ]

        return parser
    }
}
