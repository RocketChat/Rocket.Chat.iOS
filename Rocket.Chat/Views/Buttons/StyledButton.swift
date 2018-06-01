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
    var fontWeight = UIFont.Weight.regular
    @IBInspectable var fontWeightDescription: String = "Regular" {
        didSet {
            switch fontWeightDescription {
            case "Regular":
                fontWeight = UIFont.Weight.regular
            case "Light":
                fontWeight = UIFont.Weight.light
            case "Medium":
                fontWeight = UIFont.Weight.medium
            default:
                fontWeight = UIFont.Weight.regular
            }
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var buttonColor: UIColor = UIColor.RCSkyBlue()
    @IBInspectable var borderColor: UIColor = UIColor.RCSkyBlue()
    @IBInspectable var textColor: UIColor = UIColor.white
    @IBInspectable var fontSize: CGFloat = 16.0
    @IBInspectable var styleRaw: Int = 0 {
        didSet {
            style = Style(rawValue: styleRaw)!
        }
    }

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return activity
    }()

    var isLoading = false
    var titleBeforeLoading: String?

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        applyStyle()
    }

    // MARK: Style Modifiers

    func applyStyle() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        switch style {
        case .solid:
            backgroundColor = buttonColor
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            setTitleColor(textColor, for: UIControlState())
            setTitleShadowColor(nil, for: UIControlState())
            titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        case .outline:
            backgroundColor = UIColor.clear
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            setTitleColor(borderColor, for: UIControlState())
            titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }

    // MARK: - Loading

    func startLoading() {
        isLoading = true
        titleBeforeLoading = title(for: UIControlState())
        setTitle(nil, for: UIControlState())

        switch style {
        case .solid:
            if buttonColor.isBrightColor() {
                loadingIndicator.activityIndicatorViewStyle = .gray
            } else {
                loadingIndicator.activityIndicatorViewStyle = .white
            }
        case .outline:
            loadingIndicator.color = borderColor
            loadingIndicator.tintColor = borderColor
        }

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
        setTitle(titleBeforeLoading, for: UIControlState())
    }

}
