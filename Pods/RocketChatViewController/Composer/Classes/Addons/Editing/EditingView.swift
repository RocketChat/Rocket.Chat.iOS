//
//  EditingView.swift
//  DifferenceKit
//
//  Created by Matheus Cardoso on 9/28/18.
//

import UIKit

public protocol EditingViewDelegate: class {
    func editingViewDidHide(_ editingView: EditingView)
    func editingViewDidShow(_ editingView: EditingView)
}

public class EditingView: UIView, ComposerLocalizable {
    public weak var delegate: EditingViewDelegate?

    public let titleLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = localized(.editingViewTitle)
        $0.font = .preferredFont(forTextStyle: .headline)
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

    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }

    override public var isHidden: Bool {
        didSet {
            if isHidden {
                delegate?.editingViewDidHide(self)
            } else {
                delegate?.editingViewDidShow(self)
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        let height = isHidden ? 0 : layoutMargins.top + titleLabel.intrinsicContentSize.height + layoutMargins.bottom

        return CGSize(width: super.intrinsicContentSize.width, height: height)
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
        addSubview(titleLabel)
        addSubview(closeButton)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: layoutMargins.left),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: layoutMargins.top),

            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -layoutMargins.right),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: layoutMargins.top)
        ])
    }
}

// Actions & Observers

extension EditingView {
    @objc func didPressCloseButton(_ sender: Any) {
        if sender as AnyObject === closeButton {
            UIView.animate(withDuration: 0.2) {
                self.isHidden = true
            }
        }
    }
}
