//
//  HighlightTextView.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 21.10.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class HighlightTextView: UITextView {

    override var attributedText: NSAttributedString! {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let string = attributedText else {
            return
        }

        let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(string)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let totalframe: CTFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)

        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }

        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

//        CTFrameDraw(totalframe, context)

        let lines = CTFrameGetLines(totalframe) as NSArray

        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(totalframe, CFRangeMake(0, 0), &origins)

        for index in 0..<lines.count {
            // swiftlint:disable force_cast
            let line = lines[index] as! CTLine
            // swiftlint:enable force_cast

            let glyphRuns = CTLineGetGlyphRuns(line) as NSArray

            for i in 0..<glyphRuns.count {
                // swiftlint:disable force_cast
                let run = glyphRuns[i] as! CTRun
                // swiftlint:enable force_cast

                let attributes = CTRunGetAttributes(run) as NSDictionary

                //"highlightText"
                if let color: UIColor = attributes.object(forKey: "highlightColor") as? UIColor {
                    var runBounds: CGRect = .zero
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0

                    runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                    runBounds.size.height = ascent + descent

                    let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    runBounds.origin.x = origins[index].x + xOffset
                    runBounds.origin.y = origins[index].y

                    let highlightColor = color.cgColor
                    context.setFillColor(highlightColor)
                    context.setStrokeColor(highlightColor)
                    context.strokePath()
                    context.fill(runBounds)
                }
            }
        }
    }
}
