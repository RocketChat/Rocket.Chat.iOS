//
//  Color+HexAndCSSColorNames.swift
//
//  Created by Norman Basham on 12/8/15.
//  Copyright © 2015 Black Labs. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public extension UIColor {
    
    /**
     Creates an immuatble UIColor instance specified by a hex string, CSS color name, or nil.
     
     - parameter hexString: A case insensitive String? representing a hex or CSS value e.g.
     
     - **"abc"**
     - **"abc7"**
     - **"#abc7"**
     - **"00FFFF"**
     - **"#00FFFF"**
     - **"00FFFF77"**
     - **"Orange", "Azure", "Tomato"** Modern browsers support 140 color names (<http://www.w3schools.com/cssref/css_colornames.asp>)
     - **"Clear"** [UIColor clearColor]
     - **"Transparent"** [UIColor clearColor]
     - **nil** [UIColor clearColor]
     - **empty string** [UIColor clearColor]
     */
    public convenience init(hex: String?) {
        let normalizedHexString: String = UIColor.normalize(hex)
        var c: CUnsignedInt = 0
        Scanner(string: normalizedHexString).scanHexInt32(&c)
        self.init(red:UIColorMasks.redValue(c), green:UIColorMasks.greenValue(c), blue:UIColorMasks.blueValue(c), alpha:UIColorMasks.alphaValue(c))
    }
    
    /**
     Returns a hex equivalent of this UIColor.
     
     - Parameter includeAlpha:   Optional parameter to include the alpha hex.
     
     color.hexDescription() -> "ff0000"
     
     color.hexDescription(true) -> "ff0000aa"
     
     - Returns: A new string with `String` with the color's hexidecimal value.
     */
    public func hexDescription(_ includeAlpha: Bool = false) -> String {
        if self.cgColor.numberOfComponents == 4 {
            let components = self.cgColor.components
            let red = Float((components?[0])!) * 255.0
            let green = Float((components?[1])!) * 255.0
            let blue = Float((components?[2])!) * 255.0
            let alpha = Float((components?[3])!) * 255.0
            if (includeAlpha) {
                return String.init(format: "%02x%02x%02x%02x", Int(red), Int(green), Int(blue), Int(alpha))
            } else {
                return String.init(format: "%02x%02x%02x", Int(red), Int(green), Int(blue))
            }
        } else {
            return "Color not RGB."
        }
    }
    
    fileprivate enum UIColorMasks: CUnsignedInt {
        case redMask    = 0xff000000
        case greenMask  = 0x00ff0000
        case blueMask   = 0x0000ff00
        case alphaMask  = 0x000000ff
        
        static func redValue(_ value: CUnsignedInt) -> CGFloat {
            let i: CUnsignedInt = (value & redMask.rawValue) >> 24
            let f: CGFloat = CGFloat(i)/255.0;
            return f;
        }
        
        static func greenValue(_ value: CUnsignedInt) -> CGFloat {
            let i: CUnsignedInt = (value & greenMask.rawValue) >> 16
            let f: CGFloat = CGFloat(i)/255.0;
            return f;
        }
        
        static func blueValue(_ value: CUnsignedInt) -> CGFloat {
            let i: CUnsignedInt = (value & blueMask.rawValue) >> 8
            let f: CGFloat = CGFloat(i)/255.0;
            return f;
        }
        
        static func alphaValue(_ value: CUnsignedInt) -> CGFloat {
            let i: CUnsignedInt = value & alphaMask.rawValue
            let f: CGFloat = CGFloat(i)/255.0;
            return f;
        }
    }
    
    fileprivate static func normalize(_ hex: String?) -> String {
        guard var hexString = hex else {
            return "00000000"
        }
        let cssColor = cssToHexDictionairy[hexString.uppercased()]
        if cssColor != nil {
            return cssColor! + "ff"
        }
        let hasHash : Bool = hexString.hasPrefix("#")
        if (hasHash) {
            hexString = String(hexString.dropFirst())
            
        }
        if hexString.count == 3 || hexString.count == 4 {
            let redHex = String(hexString[..<hexString.index(hexString.startIndex, offsetBy: 1)])
            let greenHex = String(hexString[Range<String.Index>(hexString.index(hexString.startIndex, offsetBy: 1) ..< hexString.index(hexString.startIndex, offsetBy: 2))])
            let blueHex = String(hexString[Range<String.Index>(hexString.index(hexString.startIndex, offsetBy: 2) ..< hexString.index(hexString.startIndex, offsetBy: 3))])
            var alphaHex = ""
            if hexString.count == 4 {
                alphaHex = String(hexString[hexString.index(hexString.startIndex, offsetBy: 3)...])
            }
            
            hexString = redHex + redHex + greenHex + greenHex + blueHex + blueHex + alphaHex + alphaHex
        }
        let hasAlpha = hexString.count > 7
        if (!hasAlpha) {
            hexString += "ff"
        }
        return hexString;
    }
    
    /**
     All modern browsers support the following 140 color names (see http://www.w3schools.com/cssref/css_colornames.asp)
     */
    fileprivate static func hexFromCssName(_ cssName: String) -> String {
        let key = cssName.uppercased()
        let hex = cssToHexDictionairy[key]
        if hex == nil {
            return cssName
        }
        return hex!
    }

    fileprivate static let cssToHexDictionairy : Dictionary<String, String> = [
        "CLEAR" : "00000000",
        "TRANSPARENT" : "00000000",
        "" : "00000000",
        "ALICEBLUE" : "F0F8FF",
        "ANTIQUEWHITE" : "FAEBD7",
        "AQUA" : "00FFFF",
        "AQUAMARINE" : "7FFFD4",
        "AZURE" : "F0FFFF",
        "BEIGE" : "F5F5DC",
        "BISQUE" : "FFE4C4",
        "BLACK" : "000000",
        "BLANCHEDALMOND" : "FFEBCD",
        "BLUE" : "0000FF",
        "BLUEVIOLET" : "8A2BE2",
        "BROWN" : "A52A2A",
        "BURLYWOOD" : "DEB887",
        "CADETBLUE" : "5F9EA0",
        "CHARTREUSE" : "7FFF00",
        "CHOCOLATE" : "D2691E",
        "CORAL" : "FF7F50",
        "CORNFLOWERBLUE" : "6495ED",
        "CORNSILK" : "FFF8DC",
        "CRIMSON" : "DC143C",
        "CYAN" : "00FFFF",
        "DARKBLUE" : "00008B",
        "DARKCYAN" : "008B8B",
        "DARKGOLDENROD" : "B8860B",
        "DARKGRAY" : "A9A9A9",
        "DARKGREY" : "A9A9A9",
        "DARKGREEN" : "006400",
        "DARKKHAKI" : "BDB76B",
        "DARKMAGENTA" : "8B008B",
        "DARKOLIVEGREEN" : "556B2F",
        "DARKORANGE" : "FF8C00",
        "DARKORCHID" : "9932CC",
        "DARKRED" : "8B0000",
        "DARKSALMON" : "E9967A",
        "DARKSEAGREEN" : "8FBC8F",
        "DARKSLATEBLUE" : "483D8B",
        "DARKSLATEGRAY" : "2F4F4F",
        "DARKSLATEGREY" : "2F4F4F",
        "DARKTURQUOISE" : "00CED1",
        "DARKVIOLET" : "9400D3",
        "DEEPPINK" : "FF1493",
        "DEEPSKYBLUE" : "00BFFF",
        "DIMGRAY" : "696969",
        "DIMGREY" : "696969",
        "DODGERBLUE" : "1E90FF",
        "FIREBRICK" : "B22222",
        "FLORALWHITE" : "FFFAF0",
        "FORESTGREEN" : "228B22",
        "FUCHSIA" : "FF00FF",
        "GAINSBORO" : "DCDCDC",
        "GHOSTWHITE" : "F8F8FF",
        "GOLD" : "FFD700",
        "GOLDENROD" : "DAA520",
        "GRAY" : "808080",
        "GREY" : "808080",
        "GREEN" : "008000",
        "GREENYELLOW" : "ADFF2F",
        "HONEYDEW" : "F0FFF0",
        "HOTPINK" : "FF69B4",
        "INDIANRED" : "CD5C5C",
        "INDIGO" : "4B0082",
        "IVORY" : "FFFFF0",
        "KHAKI" : "F0E68C",
        "LAVENDER" : "E6E6FA",
        "LAVENDERBLUSH" : "FFF0F5",
        "LAWNGREEN" : "7CFC00",
        "LEMONCHIFFON" : "FFFACD",
        "LIGHTBLUE" : "ADD8E6",
        "LIGHTCORAL" : "F08080",
        "LIGHTCYAN" : "E0FFFF",
        "LIGHTGOLDENRODYELLOW" : "FAFAD2",
        "LIGHTGRAY" : "D3D3D3",
        "LIGHTGREY" : "D3D3D3",
        "LIGHTGREEN" : "90EE90",
        "LIGHTPINK" : "FFB6C1",
        "LIGHTSALMON" : "FFA07A",
        "LIGHTSEAGREEN" : "20B2AA",
        "LIGHTSKYBLUE" : "87CEFA",
        "LIGHTSLATEGRAY" : "778899",
        "LIGHTSLATEGREY" : "778899",
        "LIGHTSTEELBLUE" : "B0C4DE",
        "LIGHTYELLOW" : "FFFFE0",
        "LIME" : "00FF00",
        "LIMEGREEN" : "32CD32",
        "LINEN" : "FAF0E6",
        "MAGENTA" : "FF00FF",
        "MAROON" : "800000",
        "MEDIUMAQUAMARINE" : "66CDAA",
        "MEDIUMBLUE" : "0000CD",
        "MEDIUMORCHID" : "BA55D3",
        "MEDIUMPURPLE" : "9370DB",
        "MEDIUMSEAGREEN" : "3CB371",
        "MEDIUMSLATEBLUE" : "7B68EE",
        "MEDIUMSPRINGGREEN" : "00FA9A",
        "MEDIUMTURQUOISE" : "48D1CC",
        "MEDIUMVIOLETRED" : "C71585",
        "MIDNIGHTBLUE" : "191970",
        "MINTCREAM" : "F5FFFA",
        "MISTYROSE" : "FFE4E1",
        "MOCCASIN" : "FFE4B5",
        "NAVAJOWHITE" : "FFDEAD",
        "NAVY" : "000080",
        "OLDLACE" : "FDF5E6",
        "OLIVE" : "808000",
        "OLIVEDRAB" : "6B8E23",
        "ORANGE" : "FFA500",
        "ORANGERED" : "FF4500",
        "ORCHID" : "DA70D6",
        "PALEGOLDENROD" : "EEE8AA",
        "PALEGREEN" : "98FB98",
        "PALETURQUOISE" : "AFEEEE",
        "PALEVIOLETRED" : "DB7093",
        "PAPAYAWHIP" : "FFEFD5",
        "PEACHPUFF" : "FFDAB9",
        "PERU" : "CD853F",
        "PINK" : "FFC0CB",
        "PLUM" : "DDA0DD",
        "POWDERBLUE" : "B0E0E6",
        "PURPLE" : "800080",
        "RED" : "FF0000",
        "ROSYBROWN" : "BC8F8F",
        "ROYALBLUE" : "4169E1",
        "SADDLEBROWN" : "8B4513",
        "SALMON" : "FA8072",
        "SANDYBROWN" : "F4A460",
        "SEAGREEN" : "2E8B57",
        "SEASHELL" : "FFF5EE",
        "SIENNA" : "A0522D",
        "SILVER" : "C0C0C0",
        "SKYBLUE" : "87CEEB",
        "SLATEBLUE" : "6A5ACD",
        "SLATEGRAY" : "708090",
        "SLATEGREY" : "708090",
        "SNOW" : "FFFAFA",
        "SPRINGGREEN" : "00FF7F",
        "STEELBLUE" : "4682B4",
        "TAN" : "D2B48C",
        "TEAL" : "008080",
        "THISTLE" : "D8BFD8",
        "TOMATO" : "FF6347",
        "TURQUOISE" : "40E0D0",
        "VIOLET" : "EE82EE",
        "WHEAT" : "F5DEB3",
        "WHITE" : "FFFFFF",
        "WHITESMOKE" : "F5F5F5",
        "YELLOW" : "FFFF00",
        "YELLOWGREEN" : "9ACD32"
    ]
}
