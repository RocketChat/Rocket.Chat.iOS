//
//  ReplyView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public class ReplyView: UIView {
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 50.0, height: 20.0)
    }

    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        self.backgroundColor = .blue

        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {

    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

        ])
    }
}
