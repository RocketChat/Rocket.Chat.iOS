//
//  TextHintCell.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public class TextHintCell: UITableViewCell {
    /*
     The hint's prefix label
     */
    public let prefixLabel: UILabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.layer.cornerRadius = Consts.prefixCornerRadius
        $0.clipsToBounds = true
        $0.backgroundColor = Consts.prefixBackgroundColor

        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1)

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: Consts.prefixWidth),
            $0.heightAnchor.constraint(equalToConstant: Consts.prefixHeight)
        ])
    }

    /*
     The hint's value label
     */
    public let valueLabel: UILabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }

    public override var intrinsicContentSize: CGSize {
        let height = layoutMargins.top + layoutMargins.bottom + valueLabel.intrinsicContentSize.height
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(prefixLabel)
        addSubview(valueLabel)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // prefixLabel

            prefixLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            prefixLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // valueLabel

            valueLabel.leadingAnchor.constraint(equalTo: prefixLabel.trailingAnchor, constant: Consts.valueLeading),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Consts

private extension TextHintCell {
    /**
     Constants for sizes and margins in the cell view.
     */
    private struct Consts {
        static var intrinsicHeight: CGFloat = 54

        static var prefixWidth: CGFloat = 30
        static var prefixHeight: CGFloat = 30
        static var prefixLeading: CGFloat = 15
        static var prefixCornerRadius: CGFloat = 4
        static var prefixBackgroundColor: UIColor = #colorLiteral(red: 0.9450980392, green: 0.9490196078, blue: 0.9568627451, alpha: 1)

        static var valueLeading: CGFloat = 15
    }
}
