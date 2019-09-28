import Foundation

open class RCBaseParser {

    public typealias RCMarkdownParserMatchBlock = ((NSTextCheckingResult, NSMutableAttributedString) -> Void)
    
    struct RCExpressionBlockPair {
        var regularExpression: NSRegularExpression
        var block: RCMarkdownParserMatchBlock
    }
    
    open var defaultAttributes = [NSAttributedString.Key: Any]()
    
    fileprivate var parsingPairs = [RCExpressionBlockPair]()
    
    open func attributedStringFromMarkdown(_ markdown: String) -> NSAttributedString? {
        return attributedStringFromMarkdown(markdown, attributes: defaultAttributes)
    }
    
    open func attributedStringFromMarkdown(_ markdown: String, attributes: [NSAttributedString.Key: Any]?) -> NSAttributedString? {
        return attributedStringFromAttributedMarkdownString(NSAttributedString(string: markdown, attributes: attributes))
    }
    
    open func attributedStringFromAttributedMarkdownString(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        for expressionBlockPair in parsingPairs {
            parseExpressionBlockPairForMutableString(mutableAttributedString, expressionBlockPair: expressionBlockPair)
        }
        
        return mutableAttributedString
    }
    
    func parseExpressionBlockPairForMutableString(_ mutableAttributedString: NSMutableAttributedString, expressionBlockPair: RCExpressionBlockPair) {
        parseExpressionForMutableString(mutableAttributedString, expression: expressionBlockPair.regularExpression, block: expressionBlockPair.block)
    }
    
    func parseExpressionForMutableString(_ mutableAttributedString: NSMutableAttributedString, expression: NSRegularExpression, block: RCMarkdownParserMatchBlock) {
        var location = 0
        
        while let match = expression.firstMatch(in: mutableAttributedString.string, options: .withoutAnchoringBounds, range: NSRange(location: location, length: mutableAttributedString.length - location)) {
            let oldLength = mutableAttributedString.length
            block(match, mutableAttributedString)
            let newLength = mutableAttributedString.length
            location = match.range.location + match.range.length + newLength - oldLength
        }
    }
    
    open func addParsingRuleWithRegularExpression(_ regularExpression: NSRegularExpression, block: @escaping RCMarkdownParserMatchBlock) {
        parsingPairs.append(RCExpressionBlockPair(regularExpression: regularExpression, block: block))
    }
    
}
