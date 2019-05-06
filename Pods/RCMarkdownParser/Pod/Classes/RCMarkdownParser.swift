import Foundation
import UIKit

private let nonBreakingSpaceCharacter = Character("\u{00A0}")

public struct RCMarkdownRegex {
    public static let CodeEscaping = "(?<!\\\\)(?:\\\\\\\\)*+(`+)(.*?[^`].*?)(\\1)(?!`)"
    public static let Escaping = "\\\\."
    public static let Unescaping = "\\\\[0-9a-z]{4}"

    public static let Header = "^(#{1,4}) (([\\S\\w\\d-_\\/\\*\\.,\\\\][ \\u00a0\\u1680\\u180e\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\ufeff]?)+)"
    public static let HeaderOptions: NSRegularExpression.Options = [.anchorsMatchLines]

    public static let List = "^( {0,%@})[\\*\\+\\-]\\s+(.+)$"
    public static let ShortList = "^( {0,%@})[\\*\\+\\-]\\s+([^\\*\\+\\-].*)$"
    public static let NumberedList = "^( {0,})[0-9]+\\.\\s(.+)$"

    public static let Quote = "(^>)(.*)$"
    public static let QuoteOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let QuoteBlock = "(>>>)\n+([\\s\\S]*?)\n+(<<<)"
    public static let QuoteBlockOptions: NSRegularExpression.Options = [.anchorsMatchLines]

    public static var allowedSchemes = ["http", "https"]
    fileprivate static var _allowedSchemes: String {
        return allowedSchemes.joined(separator: "|")
    }

    public static let Image = "!\\[([^\\]]+)\\]\\(((?:\(_allowedSchemes)):\\/\\/[^\\)]+)\\)"
    public static let ImageOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let Link = "(?<!!)\\[([^\\]]+)\\]\\(((?:\(_allowedSchemes)):\\/\\/[^\\)]+)\\)"
    public static let LinkOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let AlternateLink = "(?:<|&lt;)((?:\(_allowedSchemes)):\\/\\/[^\\|]+)\\|(.+?)(?=>|&gt;)(?:>|&gt;)"
    public static let AlternateLinkOptions: NSRegularExpression.Options = [.anchorsMatchLines]

    public static let InlineCode = "(?:^|&gt;|[ >_*~])(\\`)([^`\r\n]+)(\\`)(?:[<_*~]|\\B|\\b|$)"
    public static let InlineCodeOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let Code = "(```)(?:[a-zA-Z]+)?((?:.|\r|\n)*?)(```)"
    public static let CodeOptions: NSRegularExpression.Options = [.anchorsMatchLines]

    public static let Strong = "(?:^|&gt;|[ >_~`])(\\*{1,2})([^\\*\r\n]+)(\\*{1,2})(?:[<_~`]|\\B|\\b|$)"
    public static let StrongOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let Italic = "(?:^|&gt;|[ >*~`])(\\_{1,2})([^\\_\r\n]+)(\\_{1,2})(?:[<*~`]|\\B|\\b|$)"
    public static let ItalicOptions: NSRegularExpression.Options = [.anchorsMatchLines]
    public static let Strike = "(?:^|&gt;|[ >_*`])(\\~{1,2})([^~\r\n]+)(\\~{1,2})(?:[<_*`]|\\B|\\b|$)"
    public static let StrikeOptions: NSRegularExpression.Options = [.anchorsMatchLines]

    public static func regexForString(_ regexString: String, options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: regexString, options: options)
        } catch {
            return nil
        }
    }
}

open class RCMarkdownParser: RCBaseParser {

    public typealias RCMarkdownParserFormattingBlock = ((NSMutableAttributedString, NSRange) -> Void)
    public typealias RCMarkdownParserLevelFormattingBlock = ((NSMutableAttributedString, NSRange, Int) -> Void)

    open var headerAttributes = [UInt: [NSAttributedString.Key: Any]]()
    open var listAttributes = [[NSAttributedString.Key: Any]]()
    open var numberedListAttributes = [[NSAttributedString.Key: Any]]()
    open var quoteAttributes = [NSAttributedString.Key: Any]()
    open var quoteBlockAttributes = [NSAttributedString.Key: Any]()

    open var imageAttributes = [NSAttributedString.Key: Any]()
    open var linkAttributes = [NSAttributedString.Key: Any]()

    open var inlineCodeAttributes = [NSAttributedString.Key: Any]()
    open var codeAttributes = [NSAttributedString.Key: Any]()

    open var strongAttributes = [NSAttributedString.Key: Any]()
    open var italicAttributes = [NSAttributedString.Key: Any]()
    open var strongAndItalicAttributes = [NSAttributedString.Key: Any]()
    open var strikeAttributes = [NSAttributedString.Key: Any]()

    public typealias DownloadImageClosure = (UIImage?)->Void
    open var downloadImage: (_ path: String, _ completion: DownloadImageClosure?) -> Void = {
        _,completion in
        completion?(nil)
    }

    public static var standardParser = RCMarkdownParser()

    class func addAttributes(_ attributesArray: [[NSAttributedString.Key: Any]], atIndex level: Int, toString attributedString: NSMutableAttributedString, range: NSRange) {
        guard !attributesArray.isEmpty else { return }

        guard let newAttributes = level < attributesArray.count && level >= 0 ? attributesArray[level] : attributesArray.last else { return }

        attributedString.addAttributes(newAttributes, range: range)
    }

    public init(withDefaultParsing: Bool = true) {
        super.init()

        strongAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
        italicAttributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12)]

        var strongAndItalicFont = UIFont.systemFont(ofSize: 12)
        strongAndItalicFont = UIFont(descriptor: strongAndItalicFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])!, size: strongAndItalicFont.pointSize)
        strongAndItalicAttributes = [NSAttributedString.Key.font: strongAndItalicFont]

        if withDefaultParsing {
            addNumberedListParsingWithLeadFormattingBlock({ (attributedString, range, level) in
                RCMarkdownParser.addAttributes(self.numberedListAttributes, atIndex: level - 1, toString: attributedString, range: range)
                let substring = attributedString.attributedSubstring(from: range).string.replacingOccurrences(of: " ", with: "\(nonBreakingSpaceCharacter)")
                attributedString.replaceCharacters(in: range, with: "\(substring)")
            }, textFormattingBlock: { attributedString, range, level in
                RCMarkdownParser.addAttributes(self.numberedListAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })

            addHeaderParsingWithLeadFormattingBlock({ attributedString, range, level in
                attributedString.replaceCharacters(in: range, with: "")
            }, textFormattingBlock: { attributedString, range, level in
                if let attributes = self.headerAttributes[UInt(level)] {
                    attributedString.addAttributes(attributes, range: range)
                }
            })

            addListParsingWithLeadFormattingBlock({ attributedString, range, level in
                RCMarkdownParser.addAttributes(self.listAttributes, atIndex: level - 1, toString: attributedString, range: range)
                let indentString = String(repeating: String(nonBreakingSpaceCharacter), count: level)
                attributedString.replaceCharacters(in: range, with: "\(indentString)\u{2022}\u{00A0}")
            }, textFormattingBlock: { attributedString, range, level in
                RCMarkdownParser.addAttributes(self.listAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })

            addQuoteBlockParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.quoteBlockAttributes, range: range)
            }

            addQuoteParsingWithLeadFormattingBlock({ attributedString, range, level in
                attributedString.replaceCharacters(in: range, with: "")
            }, textFormattingBlock: { attributedString, range, level in
                attributedString.addAttributes(self.quoteAttributes, range: range)
            })

            addInlineCodeParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.inlineCodeAttributes, range: range)
            }

            addCodeParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.codeAttributes, range: range)
            }

            addStrongParsingWithFormattingBlock { attributedString, range in
                attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
                    if let font = attributes[NSAttributedString.Key.font] as? UIFont, let italicFont = self.italicAttributes[NSAttributedString.Key.font] as? UIFont, font == italicFont {
                        attributedString.addAttributes(self.strongAndItalicAttributes, range: range)
                    } else {
                        attributedString.addAttributes(self.strongAttributes, range: range)
                    }
                }
            }

            addItalicParsingWithFormattingBlock { attributedString, range in
                attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
                    if let font = attributes[NSAttributedString.Key.font] as? UIFont, let boldFont = self.strongAttributes[NSAttributedString.Key.font] as? UIFont, font == boldFont {
                        attributedString.addAttributes(self.strongAndItalicAttributes, range: range)
                    } else {
                        attributedString.addAttributes(self.italicAttributes, range: range)
                    }
                }
            }

            addStrikeParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.strikeAttributes, range: range)
            }

            addImageParsingWithImageFormattingBlock({ attributedString, range in
                attributedString.addAttributes(self.imageAttributes, range: range)
            }, alternativeTextFormattingBlock: { attributedString, range in
                attributedString.addAttributes(self.imageAttributes, range: range)
            })

            addLinkParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.linkAttributes, range: range)
            }

            addAlternateLinkParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.linkAttributes, range: range)
            }
        }
    }

    open func addEscapingParsing() {
        guard let escapingRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.Escaping) else { return }

        addParsingRuleWithRegularExpression(escapingRegex) { match, attributedString in
            let range = NSRange(location: match.range.location + 1, length: 1)
            let matchString = attributedString.attributedSubstring(from: range).string as NSString
            let escapedString = NSString(format: "%04x", matchString.character(at: 0)) as String
            attributedString.replaceCharacters(in: range, with: escapedString)
        }
    }

    open func addCodeEscapingParsing() {
        guard let codingParsingRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.CodeEscaping) else { return }

        addParsingRuleWithRegularExpression(codingParsingRegex) { match, attributedString in
            let range = match.range(at: 2)
            let matchString = attributedString.attributedSubstring(from: range).string as NSString

            var escapedString = ""
            for index in 0..<range.length {
                escapedString = "\(escapedString)\(NSString(format: "%04x", matchString.character(at: index)))"
            }

            attributedString.replaceCharacters(in: range, with: escapedString)
        }
    }

    fileprivate func addLeadParsingWithPattern(_ pattern: String, maxLevel: Int?, leadFormattingBlock: @escaping RCMarkdownParserLevelFormattingBlock, formattingBlock: RCMarkdownParserLevelFormattingBlock?) {
        let regexString: String = {
            let maxLevel: Int = maxLevel ?? 0
            return NSString(format: pattern as NSString, maxLevel > 0 ? "\(maxLevel)" : "") as String
        }()

        guard let regex = RCMarkdownRegex.regexForString(regexString, options: .anchorsMatchLines) else { return }

        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            let level = match.range(at: 1).length
            formattingBlock?(attributedString, match.range(at: 2), level)
            leadFormattingBlock(attributedString, NSRange(location: match.range(at: 1).location, length: match.range(at: 2).location - match.range(at: 1).location), level)
        }
    }

    open func addHeaderParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping RCMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: RCMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(RCMarkdownRegex.Header, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }

    open func addListParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping RCMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: RCMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(RCMarkdownRegex.List, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }

    open func addNumberedListParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping RCMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: RCMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(RCMarkdownRegex.NumberedList, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }

    open func addQuoteParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping RCMarkdownParserLevelFormattingBlock, textFormattingBlock formattingBlock: RCMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(RCMarkdownRegex.Quote, maxLevel: 1, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }

    open func addQuoteBlockParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.QuoteBlock, formattingBlock: formattingBlock)
    }

    open func addImageParsingWithImageFormattingBlock(_ formattingBlock: RCMarkdownParserFormattingBlock?, alternativeTextFormattingBlock alternateFormattingBlock: RCMarkdownParserFormattingBlock?) {
        guard let headerRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.Image, options: RCMarkdownRegex.ImageOptions) else { return }

        addParsingRuleWithRegularExpression(headerRegex) { match, attributedString in
            let imagePathStart = (attributedString.string as NSString).range(of: "(", options: [], range: match.range).location
            let linkRange = NSRange(location: imagePathStart, length: match.range.length + match.range.location - imagePathStart - 1)
            let imagePath = (attributedString.string as NSString).substring(with: NSRange(location: linkRange.location + 1, length: linkRange.length - 1))

            let linkTextEndLocation = (attributedString.string as NSString).range(of: "]", options: [], range: match.range).location
            let linkTextRange = NSRange(location: match.range.location + 2, length: linkTextEndLocation - match.range.location - 2)
            let alternativeText = (attributedString.string as NSString).substring(with: linkTextRange)
            attributedString.replaceCharacters(in: match.range, with: alternativeText)

            let alternativeRange = NSRange(location: match.range.location, length: (alternativeText as NSString).length)
            attributedString.addAttribute(NSAttributedString.Key.link, value: imagePath, range: alternativeRange)
            alternateFormattingBlock?(attributedString, alternativeRange)

            self.downloadImage(imagePath) { image in
                if let image = image {
                    let imageAttatchment = NSTextAttachment()
                    imageAttatchment.image = image
                    imageAttatchment.bounds = CGRect(x: 0, y: -5, width: image.size.width, height: image.size.height)
                    let imageString = NSAttributedString(attachment: imageAttatchment)
                    attributedString.replaceCharacters(in: NSRange(location: match.range.location, length: alternativeText.count), with: imageString)
                    formattingBlock?(attributedString, NSRange(location: match.range.location, length: 1))
                }
            }
        }
    }

    open func addLinkParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        guard let linkRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.Link, options: RCMarkdownRegex.LinkOptions) else { return }

        addParsingRuleWithRegularExpression(linkRegex) { [weak self] match, attributedString in
            let linkStartinResult = (attributedString.string as NSString).range(of: "(", options: .backwards, range: match.range).location
            let linkRange = NSRange(location: linkStartinResult, length: match.range.length + match.range.location - linkStartinResult - 1)
            let linkUrlString = (attributedString.string as NSString).substring(with: NSRange(location: linkRange.location + 1, length: linkRange.length - 1))

            let linkTextRange = NSRange(location: match.range.location + 1, length: linkStartinResult - match.range.location - 2)
            attributedString.deleteCharacters(in: NSRange(location: linkRange.location - 1, length: linkRange.length + 2))

            if let linkUrlString = self?.unescaped(string: linkUrlString), let url = URL(string: linkUrlString) ?? URL(string: linkUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? linkUrlString) {
                attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: linkTextRange)
            }
            formattingBlock(attributedString, linkTextRange)

            attributedString.deleteCharacters(in: NSRange(location: match.range.location, length: 1))
        }
    }

    open func addAlternateLinkParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        guard let linkRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.AlternateLink, options: RCMarkdownRegex.AlternateLinkOptions)
            else { return }

        addParsingRuleWithRegularExpression(linkRegex) { [weak self] match, attributedString in
            func string() -> NSString { return attributedString.string as NSString }
            let linkEnd = string().range(of: "|", options: .backwards, range: match.range)
            let linkStart = string().range(of: "<", options: .backwards, range: NSRange(location: match.range.location, length: linkEnd.location - match.range.location))
            let linkRange = NSRange(location: linkStart.location, length: linkEnd.location - linkStart.location + 1)
            let linkUrlRange = NSRange(location: linkRange.location + 1, length: linkRange.length - 2)
            let linkUrlString = string().substring(with: linkUrlRange)

            let linkTextLength = match.range.length + match.range.location - linkEnd.location - 1
            let linkTextRange = NSRange(location: linkEnd.location + 1, length: linkTextLength)

            let linkTextString = string().substring(with: linkTextRange)

            attributedString.deleteCharacters(in: NSRange(location: linkRange.location, length: linkRange.length))

            if let linkUrlString = self?.unescaped(string: linkUrlString), let url = URL(string: linkUrlString) ?? URL(string: linkUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? linkUrlString) {
                attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: string().range(of: linkTextString))
            }

            attributedString.deleteCharacters(in: string().range(of: ">", options: .backwards))
        }
    }

    fileprivate func addEnclosedParsingWithPattern(_ pattern: String, options: NSRegularExpression.Options = [], formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        guard let regex = RCMarkdownRegex.regexForString(pattern, options: options) else { return }

        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            attributedString.deleteCharacters(in: match.range(at: 3))
            formattingBlock(attributedString, match.range(at: 2))
            attributedString.deleteCharacters(in: match.range(at: 1))
        }
    }

    open func addInlineCodeParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.InlineCode, options: RCMarkdownRegex.InlineCodeOptions, formattingBlock: formattingBlock)
    }

    open func addCodeParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.Code, formattingBlock: formattingBlock)
    }

    open func addStrongParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.Strong, options: RCMarkdownRegex.StrongOptions, formattingBlock: formattingBlock)
    }

    open func addItalicParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.Italic, options: RCMarkdownRegex.ItalicOptions, formattingBlock: formattingBlock)
    }

    open func addStrikeParsingWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(RCMarkdownRegex.Strike, options: RCMarkdownRegex.StrikeOptions, formattingBlock: formattingBlock)
    }

    open func addLinkDetectionWithFormattingBlock(_ formattingBlock: @escaping RCMarkdownParserFormattingBlock) {
        do {
            let linkDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            addParsingRuleWithRegularExpression(linkDataDetector) { [weak self] match, attributedString in
                if let urlString = match.url?.absoluteString.removingPercentEncoding, let unescapedUrlString = self?.unescaped(string: urlString), let url = URL(string: unescapedUrlString) {
                    attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: match.range)
                }
                formattingBlock(attributedString, match.range)
            }
        } catch { }
    }

    func unescaped(string: String) -> String? {
        guard let unescapingRegex = RCMarkdownRegex.regexForString(RCMarkdownRegex.Unescaping, options: .dotMatchesLineSeparators) else { return nil }

        var location = 0
        let unescapedMutableString = NSMutableString(string: string)
        while let match = unescapingRegex.firstMatch(in: unescapedMutableString as String, options: .withoutAnchoringBounds, range: NSRange(location: location, length: unescapedMutableString.length - location)) {
            let oldLength = unescapedMutableString.length
            let range = NSRange(location: match.range.location + 1, length: 4)
            let matchString = unescapedMutableString.substring(with: range)
            let unescapedString = RCMarkdownParser.stringWithHexaString(matchString, atIndex: 0)
            unescapedMutableString.replaceCharacters(in: match.range, with: unescapedString)
            let newLength = unescapedMutableString.length
            location = match.range.location + match.range.length + newLength - oldLength
        }

        return unescapedMutableString as String
    }

    fileprivate class func stringWithHexaString(_ hexaString: String, atIndex index: Int) -> String {
        let range = hexaString.index(hexaString.startIndex, offsetBy: index)..<hexaString.index(hexaString.startIndex, offsetBy: index + 4)
        let sub = hexaString.substring(with: range)

        let char = Character(UnicodeScalar(Int(strtoul(sub, nil, 16)))!)
        return "\(char)"
    }
}
