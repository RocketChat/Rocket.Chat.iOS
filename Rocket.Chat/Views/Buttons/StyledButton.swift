//
//  StyledButton.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 01/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class StyledButton: UIButton {

    // MARK: - Nested Types

    enum Style: Int {
        case solid = 0, outline
    }

    // MARK: - Properties

    var style = Style.solid
    var fontTraits: UIFontDescriptor.SymbolicTraits?
    var fontStyle: UIFont.TextStyle = .body

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var buttonColorDisabled: UIColor = UIColor(red: 225/255, green: 229/255, blue: 232/255, alpha: 1)
    @IBInspectable var buttonColor: UIColor = UIColor.RCSkyBlue()
    @IBInspectable var borderColor: UIColor = UIColor.RCSkyBlue()
    @IBInspectable var textColor: UIColor = UIColor.white
    @IBInspectable var styleRaw: Int = 0 {
        didSet {
            guard let style = Style(rawValue: styleRaw) else {
                return assertionFailure("Value inputed on IB doesn't match any valid option")
            }

            self.style = style
        }
    }

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        return activity
    }()

    var isLoading = false
    var titleBeforeLoading: String?

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = contentRect
        imageRect.origin = CGPoint(x: 15, y: 11)
        imageRect.size = CGSize(width: 24, height: 24)
        return imageRect
    }

    // MARK: Style Modifiers

    func applyStyle() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        if !isEnabled {
            backgroundColor = buttonColorDisabled
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            setTitleColor(.white, for: UIControl.State())
            setTitleShadowColor(nil, for: UIControl.State())
            return
        }

        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        setTitleColor(textColor, for: UIControl.State())

        var font = UIFont.preferredFont(forTextStyle: fontStyle)
        if let fontTraits = fontTraits {
            font = font.withTraits(fontTraits) ?? font
        }

        titleLabel?.font = font

        switch style {
        case .solid:
            backgroundColor = buttonColor
            setTitleShadowColor(nil, for: UIControl.State())
        case .outline:
            backgroundColor = UIColor.clear
        }
    }

    override var isEnabled: Bool {
        didSet {
            applyStyle()
        }
    }

    // MARK: - Loading

    func startLoading() {
        isLoading = true
        titleBeforeLoading = title(for: UIControl.State())
        setTitle(nil, for: UIControl.State())

        switch style {
        case .solid:
            loadingIndicator.color = .white
            loadingIndicator.tintColor = .white
        case .outline:
            loadingIndicator.color = borderColor
            loadingIndicator.tintColor = borderColor
        }

        setNeedsLayout()
        layoutIfNeeded()
        let width = frame.width
        loadingIndicator.frame = CGRect(
            x: (width / 2 - loadingIndicator.frame.width / 2),
            y: (frame.height / 2 - loadingIndicator.frame.height / 2),
            width: loadingIndicator.frame.width,
            height: loadingIndicator.frame.height
        )

        addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }

    func stopLoading() {
        isLoading = false
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
        setTitle(titleBeforeLoading, for: UIControl.State())
    }

    override func applyTheme() {
        super.applyTheme()
        applyStyle()
    }

}
