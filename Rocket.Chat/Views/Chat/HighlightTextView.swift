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

        text = nil

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

        guard let lines = CTFrameGetLines(totalframe) as? [CTLine] else {
            return
        }

        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(totalframe, CFRangeMake(0, lines.count), &origins)

        for index in 0..<lines.count {
            let line: CTLine = lines[index]

            guard let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun] else {
                continue
            }

            for i in 0..<glyphRuns.count {
                let run: CTRun = glyphRuns[i]

                let attributes = CTRunGetAttributes(run) as NSDictionary
                let dicObject = attributes.object(forKey: NSAttributedStringKey.highlightBackgroundColor)

                if let color: UIColor = dicObject as? UIColor {
                    var runBounds: CGRect = .zero
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0

                    let width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil)
                    runBounds.size.width = CGFloat(width)
                    runBounds.size.height = ascent + descent

                    let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    runBounds.origin.x = origins[index].x + xOffset
                    runBounds.origin.y = origins[index].y - 4

                    drawBackground(runBounds, color, context)
                }
            }
        }

        CTFrameDraw(totalframe, context)
    }

    private func drawBackground(_ runBounds: CGRect, _ color: UIColor, _ context: CGContext) {
        let path = UIBezierPath(roundedRect: runBounds, cornerRadius: 3)

        let highlightColor = color.cgColor
        context.setFillColor(highlightColor)
        context.setStrokeColor(highlightColor)
        context.addPath(path.cgPath)
        context.drawPath(using: .fillStroke)
    }
}
