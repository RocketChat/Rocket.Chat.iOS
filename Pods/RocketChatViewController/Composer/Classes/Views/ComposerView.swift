//
//  ComposerView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import NotificationCenter

/**
 An enum that represents a place in the composer view where an addon is placed.
 */
public enum ComposerAddonSlot {
    /**
     When the addon represents something in the message (eg. attached media)
     */
    case component

    /**
     When the addon represents a utility to the composer (eg. hint view)
     */
    case utility
}

/*
 A default composer view delegate with fallback behaviors.
 */
private class ComposerViewFallbackDelegate: ComposerViewDelegate { }

// MARK: Initializers
public class ComposerView: UIView {
    /**
     The object that acts as the delegate of the composer.
     */
    public weak var delegate: ComposerViewDelegate?

    /**
     A fallback delegate for when delegate is nil.
     */
    private var fallbackDelegate = ComposerViewFallbackDelegate()

    /**
     Returns the delegate if set, if not, returns the default delegate.

     Delegate should only be accessed inside this class via this computed property.
     */
    private var currentDelegate: ComposerViewDelegate {
        return delegate ?? fallbackDelegate
    }

    /**
     The view that contains all subviews
     */
    public let containerView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }

    /**
     The button that stays in the left side of the composer.
     */
    public let leftButton = tap(ComposerButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setBackgroundImage(ComposerAsset.addButton.raw, for: .normal)

        $0.addTarget(self, action: #selector(touchUpInside(button:)), for: .touchUpInside)

        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    /**
     The button that stays in the right side of the composer.
     */
    public let rightButton = tap(ComposerButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setBackgroundImage(ComposerAsset.sendButton.raw, for: .normal)

        $0.addTarget(self, action: #selector(touchUpInside(button:)), for: .touchUpInside)

        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    /**
     The text view used to compose the message.
     */
    public let textView = tap(ComposerTextView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = ""
        $0.placeholderLabel.text = "Type a message"
        $0.placeholderLabel.font = .preferredFont(forTextStyle: .body)
        $0.placeholderLabel.adjustsFontForContentSizeCategory = true

        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }

    /**
     The view that contains component addons on top of the text (eg. attached media)
     */
    public let componentStackView = tap(ComposerAddonStackView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
    }

    /**
     The separator line on top of the composer
     */
    public let topSeparatorView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.8980392157, blue: 0.9098039216, alpha: 1)

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    /**
     The view that contains utility addons on top of the composer (eg. hint view)
     */
    public let utilityStackView = tap(ComposerAddonStackView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: containerView.bounds.height)
    }

    public convenience init() {
        self.init(frame: .zero)
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
    public func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false

        leftButton.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)

        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        textView.delegate = self

        containerView.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)

        addSubviews()
        setupConstraints()

        containerView.backgroundColor = .white
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(containerView)

        containerView.addSubview(leftButton)
        containerView.addSubview(rightButton)
        containerView.addSubview(textView)
        containerView.addSubview(componentStackView)
        containerView.addSubview(topSeparatorView)
        containerView.addSubview(utilityStackView)
    }

    // MARK: Constraints

    lazy var textViewLeadingConstraint: NSLayoutConstraint = {
        textView.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: layoutMargins.left)
    }()

    lazy var containerViewLeadingConstraint: NSLayoutConstraint = {
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    }()

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // containerView constraints

            containerViewLeadingConstraint,
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // utilityStackView constraints

            utilityStackView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            utilityStackView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor),
            utilityStackView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            utilityStackView.bottomAnchor.constraint(equalTo: topSeparatorView.topAnchor),

            // topSeparatorView constraints

            topSeparatorView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor),
            topSeparatorView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            topSeparatorView.bottomAnchor.constraint(equalTo: componentStackView.topAnchor),

            // componentStackView constraints

            componentStackView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            componentStackView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor),
            componentStackView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            componentStackView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -10),

            // textView constraints

            textViewLeadingConstraint,
            textView.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -layoutMargins.right),
            textView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -layoutMargins.bottom),

            // rightButton constraints

            rightButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -layoutMargins.right*2),
            rightButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant:  -layoutMargins.bottom*2),

            // leftButton constraints

            leftButton.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: layoutMargins.left*2),
            leftButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -layoutMargins.bottom*2)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        reloadAddons()
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in self.subviews {
            if view.isUserInteractionEnabled, view.point(inside: self.convert(point, to: view), with: event) {
                return true
            }
        }

        return false
    }
}

// MARK: Addons

public extension ComposerView {
    func reloadAddons() {
        [
            (componentStackView, ComposerAddonSlot.component),
            (utilityStackView, ComposerAddonSlot.utility)
        ].forEach { (stackView, slot) in
            stackView.subviews.forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

            for index in 0..<currentDelegate.numberOfAddons(in: self, at: slot) {
                if let addon = currentDelegate.composerView(self, addonAt: slot, index: index) {
                    let addonView: UIView = addon.viewType.init()
                    addonView.frame = stackView.frame
                    stackView.addArrangedSubview(addonView)

                    currentDelegate.composerView(self, didUpdateAddonView: addonView, at: slot, index: index)
                } else {
                    currentDelegate.composerView(self, didUpdateAddonView: nil, at: slot, index: index)
                }
            }
        }
    }
}

// MARK: Observers & Actions

public extension ComposerView {
    /**
     Called when the content size of the text view changes and adjusts the composer height constraint.
     */
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === leftButton && keyPath == "bounds" {
            textViewLeadingConstraint.constant = leftButton.isHidden ? 0 : layoutMargins.left
        }

        if object as AnyObject? === containerView && keyPath == "bounds" {
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
        }

        if object as AnyObject? === textView && keyPath == "contentSize" {
            textView.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }

    /**
     Called when a touch up inside happens in one of the buttons.
     */
    @objc func touchUpInside(button: ComposerButton) {
        currentDelegate.composerView(self, didTapButton: button)
    }
}

// MARK: UITextView Delegate
extension ComposerView: UITextViewDelegate {
    @objc public func textViewDidChangeSelection(_ textView: UITextView) {
        currentDelegate.composerViewDidChangeSelection(self)
        return
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // it would be good if we could support "soft return"
        // (shift+enter) to allow the user to type newlines
        // but as of iOS 12, it's not possible yet :(
        if text == "\n" {
            return currentDelegate.composerViewShouldReturn(self)
        }

        return true
    }
}
