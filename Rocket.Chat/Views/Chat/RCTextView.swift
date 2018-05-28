//
//  RCTextView.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 21.10.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class HighlightLayoutManager: NSLayoutManager {
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {
        let cornerRadius: CGFloat = 5
        let path = CGMutablePath.init()

        if rectCount == 1 || (rectCount == 2 && (rectArray[1].maxX < rectArray[0].maxX)) {
            path.addRect(rectArray[0].insetBy(dx: cornerRadius, dy: cornerRadius))

            if rectCount == 2 {
                path.addRect(rectArray[1].insetBy(dx: cornerRadius, dy: cornerRadius))
            }
        } else {
            let lastRect = rectCount - 1

            path.move(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].minY + cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[0].minY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.closeSubpath()
        }

        color.set()

        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.setLineWidth(cornerRadius * 1.9)
        ctx.setLineJoin(.round)

        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)

        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }
}

@IBDesignable class RCTextView: UIView {

    private var textView: UITextView!
    private var customEmojiViews: [EmojiView] = []

    weak var delegate: ChatMessageCellProtocol?

    var message: NSAttributedString! {
        didSet {
            textView.attributedText = message
            updateCustomEmojiViews()
        }
    }

    func updateCustomEmojiViews() {
        customEmojiViews.forEach { $0.removeFromSuperview() }
        customEmojiViews.removeAll()
        addCustomEmojiIfNeeded()
    }

    func addCustomEmojiIfNeeded() {
        message?.enumerateAttributes(in: NSRange(location: 0, length: message.length), options: [], using: { attributes, crange, _ in
            if let attachment = attributes[NSAttributedStringKey.attachment] as? NSTextAttachment {
                DispatchQueue.main.async {
                    guard let position1 = self.textView.position(from: self.textView.beginningOfDocument, offset: crange.location) else { return }
                    guard let position2 = self.textView.position(from: position1, offset: crange.length) else { return }
                    guard let range = self.textView.textRange(from: position1, to: position2) else { return }

                    let rect = self.textView.firstRect(for: range)

                    let emojiView = EmojiView(frame: rect)
                    emojiView.backgroundColor = .white
                    emojiView.isUserInteractionEnabled = false

                    if let imageUrlData = attachment.contents,
                            let imageUrlString = String(data: imageUrlData, encoding: .utf8),
                            let imageUrl = URL(string: imageUrlString) {
                        ImageManager.loadImage(with: imageUrl, into: emojiView.emojiImageView)
                        self.customEmojiViews.append(emojiView)
                        self.addSubview(emojiView)
                    }
                }
            }
        })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let textStorage = NSTextStorage()
        let layoutManager = HighlightLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer.init(size: bounds.size)
        layoutManager.addTextContainer(textContainer)
        textView = UITextView.init(frame: .zero, textContainer: textContainer)
        configureTextView()

        addSubview(textView)
    }

    private func configureTextView() {
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = .all
        textView.isEditable = false
        textView.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textView.frame = bounds
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        textView.text = "HighlightTextView"
    }
}

extension RCTextView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "http" || URL.scheme == "https" {
            delegate?.openURL(url: URL)
            return false
        }

        if let deepLink = DeepLink(url: URL) {
            guard
                case let .mention(name) = deepLink,
                let user = User.find(username: name),
                let start = textView.position(from: textView.beginningOfDocument, offset: characterRange.location),
                let end = textView.position(from: start, offset: characterRange.length),
                let range = textView.textRange(from: start, to: end)
            else {
                return false
            }

            MainSplitViewController.chatViewController?.presentActionSheetForUser(user, source: (textView, textView.firstRect(for: range)))
        }

        return false
    }

}
