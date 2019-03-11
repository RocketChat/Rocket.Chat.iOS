import Foundation
import UIKit

public extension NSAttributedString {
    
    public func markdownString() -> String {
        let bulletCharacter = Character("\u{2022}")
        let nonBreakingSpaceCharacter = Character("\u{00A0}")
        
        var markdownString = ""
        
        enum FormattingChange {
            case enable
            case disable
            case keep
            
            static func getFormattingChange(_ before: Bool, after: Bool) -> FormattingChange {
                if !before && after { return .enable }
                if before && !after { return .disable }
                return .keep
            }
        }
        
        var stringHasBoldEnabled = false
        var stringHasItalicEnabled = false
        var closingString = ""
        var characterOnBulletedListLine = false
        var openedNumberedListStarter = false
        var characterOnNumberedListLine = false
        var numberedListIsFirstLine = false
        var previousCharacter: Character?
        enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { attributes, range, shouldStop in
            if let traits = (attributes[NSAttributedString.Key.font] as? UIFont)?.fontDescriptor.symbolicTraits {
                let boldChange = FormattingChange.getFormattingChange(stringHasBoldEnabled, after: traits.contains(.traitBold))
                let italicChange = FormattingChange.getFormattingChange(stringHasItalicEnabled, after: traits.contains(.traitItalic))
                var formatString = ""
                switch boldChange {
                case .enable:
                    formatString += "**"
                    closingString = "**\(closingString)"
                case .disable:
                    if stringHasItalicEnabled && italicChange == .keep {
                        formatString += "_**_"
                        closingString = "_"
                    } else {
                        formatString += "**"
                        closingString = ""
                    }
                case .keep:
                    break
                }
                
                switch italicChange {
                case .enable:
                    formatString += "_"
                    closingString = "_\(closingString)"
                case .disable:
                    if stringHasBoldEnabled && boldChange == .keep {
                        formatString = "**_**\(formatString)"
                        closingString = "**"
                    } else {
                        formatString = "_\(formatString)"
                        closingString = ""
                    }
                case .keep:
                    break
                }
                
                markdownString += formatString
                
                stringHasBoldEnabled = traits.contains(.traitBold)
                stringHasItalicEnabled = traits.contains(.traitItalic)
            }
            
            let preprocessedString = (self.string as NSString).substring(with: range)
            let processedString = preprocessedString.reduce("") { resultString, character in
                var stringToAppend = ""
                
                switch character {
                case "\\", "`", "*", "_", "{", "}", "[", "]", "(", ")", "#", "+", "-", "!":
                    stringToAppend = "\\\(character)"
                case "\n", "\u{2028}":
                    stringToAppend = "\(closingString)\(character)"
                    if !characterOnBulletedListLine && !characterOnNumberedListLine {
                        stringToAppend += String(closingString.reversed())
                    }
                    
                    characterOnBulletedListLine = false
                    characterOnNumberedListLine = false
                case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
                    if previousCharacter == "\n" || previousCharacter == nil || previousCharacter == nonBreakingSpaceCharacter {
                        openedNumberedListStarter = true
                    }
                    
                    numberedListIsFirstLine = previousCharacter == nil ? true : numberedListIsFirstLine
                    stringToAppend = "\(character)"
                case bulletCharacter:
                    characterOnBulletedListLine = true
                    stringToAppend = "+ \(previousCharacter != nil ? String(closingString.reversed()) : markdownString)"
                    markdownString = previousCharacter == nil ? "" : markdownString
                case ".":
                    if openedNumberedListStarter {
                        openedNumberedListStarter = false
                        characterOnNumberedListLine = true
                        
                        stringToAppend = "\(character) \(!numberedListIsFirstLine ? String(closingString.reversed()) : markdownString)"
                        
                        if numberedListIsFirstLine {
                            markdownString = ""
                            numberedListIsFirstLine = false
                        }
                        break
                    }
                    stringToAppend = "\\\(character)"
                case nonBreakingSpaceCharacter:
                    if characterOnBulletedListLine || characterOnNumberedListLine {
                        break
                    }
                    stringToAppend = " "
                default:
                    if (previousCharacter == "\n" || previousCharacter == "\u{2028}") && characterOnBulletedListLine {
                        characterOnBulletedListLine = false
                        stringToAppend = "\(String(closingString.reversed()))\(character)"
                    } else {
                        stringToAppend = "\(character)"
                    }
                }
                
                previousCharacter = character
                return "\(resultString)\(stringToAppend)"
            }
            markdownString += processedString
        }
        markdownString += closingString
        markdownString = markdownString.replacingOccurrences(of: "**__**", with: "").replacingOccurrences(of: "****", with: "")
            .replacingOccurrences(of: "__", with: "")
        // Help the user because they probably didn't intend to have empty bullets and it will make markdown have a + if we leave them
        markdownString = markdownString.replacingOccurrences(of: "+ \n", with:  "")
        if markdownString.hasSuffix("+ ") {
            markdownString = (markdownString as NSString).substring(to: markdownString.count - 2)
        }
        
        return markdownString
    }
    
}
