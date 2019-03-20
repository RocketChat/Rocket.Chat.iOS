//
//  ReplyView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public struct ReplyViewModel {
    public var nameText: String
    public var timeText: String
    public var text: String

    public init(nameText: String, timeText: String, text: String) {
        self.nameText = nameText
        self.timeText = timeText
        self.text = text
    }
}

public protocol ReplyViewDelegate: class {
    func replyViewDidHide(_ replyView: ReplyView)
    func replyViewDidShow(_ replyView: ReplyView)
}

public class ReplyView: UIView {

    public weak var delegate: ReplyViewDelegate?

    public let backgroundView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9607843137, alpha: 1)
        $0.layer.cornerRadius = 4.0
    }

    public let nameLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "jaad.brinkley"
        $0.textColor = #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1)
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    public let timeLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "2:10 PM"
        $0.textColor = #colorLiteral(red: 0.6196078431, green: 0.6352941176, blue: 0.6588235294, alpha: 1)
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true
    }

    public let textLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "This is a multiline chat message from a person that sent a message"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    public let closeButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 20),
            $0.heightAnchor.constraint(equalToConstant: 20)
        ])

        $0.setBackgroundImage(ComposerAssets.cancelReplyButtonImage, for: .normal)
        $0.tintColor = #colorLiteral(red: 0.6196078431, green: 0.6352941176, blue: 0.6588235294, alpha: 1)

        $0.addTarget(self, action: #selector(didPressCloseButton(_:)), for: .touchUpInside)
    }

    override public var isHidden: Bool {
        didSet {
            if isHidden {
                delegate?.replyViewDidHide(self)
            } else {
                delegate?.replyViewDidShow(self)
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        let height = isHidden ? 0 : 10 +
            nameLabel.intrinsicContentSize.height +
            textLabel.intrinsicContentSize.height +
            3 + 15 + 13

        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }


    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
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
        clipsToBounds = true
        isHidden = true

        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(backgroundView)

        backgroundView.addSubview(nameLabel)
        backgroundView.addSubview(timeLabel)
        backgroundView.addSubview(textLabel)

        addSubview(closeButton)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            backgroundView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10),
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            nameLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 13),

            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            timeLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -15),

            textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0),
            textLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            textLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),

            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        ])
    }
}

// Actions & Observers

extension ReplyView {
    @objc func didPressCloseButton(_ sender: Any) {
        if sender as AnyObject === closeButton {
            UIView.animate(withDuration: 0.2) {
                self.isHidden = true
            }
        }
    }
}
