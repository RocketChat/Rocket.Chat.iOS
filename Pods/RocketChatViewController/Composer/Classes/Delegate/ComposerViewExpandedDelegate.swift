//
//  ComposerViewExpandedDelegate.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation

private extension ComposerView {
    var hintsView: HintsView? {
        return utilityStackView.subviews.first(where: { $0 as? HintsView != nil }) as? HintsView
    }

    var replyView: ReplyView? {
        return componentStackView.subviews.first(where: { $0 as? ReplyView != nil }) as? ReplyView
    }

    var editingView: EditingView? {
        return componentStackView.subviews.first(where: { $0 as? EditingView != nil }) as? EditingView
    }

    var recordAudioView: RecordAudioView? {
        return overlayView.subviews.first(where: { $0 as? RecordAudioView != nil }) as? RecordAudioView
    }
}

/**
 An expanded child of the ComposerViewDelegate protocol.
 This adds default implementatios for reply, autocompletion and more.
 */
public protocol ComposerViewExpandedDelegate: ComposerViewDelegate,
                                              HintsViewDelegate,
                                              ReplyViewDelegate,
                                              EditingViewDelegate,
                                              RecordAudioViewDelegate,
                                              PreviewAudioViewDelegate {

    func hintPrefixes(for composerView: ComposerView) -> [Character]
    func isHinting(in composerView: ComposerView) -> Bool

    func composerView(_ composerView: ComposerView, didChangeHintPrefixedWord word: String)
    func composerView(_ composerView: ComposerView, didPressSendButton button: UIButton)
    func composerView(_ composerView: ComposerView, didPressUploadButton button: UIButton)
    func composerView(_ composerView: ComposerView, didPressRecordAudioButton button: UIButton)
    func composerView(_ composerView: ComposerView, didReleaseRecordAudioButton button: UIButton)
    func composerView(_ composerView: ComposerView, didDragRecordAudioButton button: UIButton, delta: CGFloat)
    func composerView(_ composerView: ComposerView, didFinishRecordingAudio url: URL)
}

public extension ComposerViewExpandedDelegate {
    func composerViewDidChangeSelection(_ composerView: ComposerView) {
        func didChangeHintPrefixedWord(_ word: String) {
            self.composerView(composerView, didChangeHintPrefixedWord: word)

            guard let hintsView = composerView.hintsView else {
                return
            }

            UIView.animate(withDuration: 0.2) {
                hintsView.reloadData()
                hintsView.invalidateIntrinsicContentSize()
                hintsView.layoutIfNeeded()
            }
        }

        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let word = String(composerView.textView.text[range])

            if let char = word.first, hintPrefixes(for: composerView).contains(char) {
                didChangeHintPrefixedWord(word)
            } else {
                didChangeHintPrefixedWord("")
            }
        } else {
            didChangeHintPrefixedWord("")
        }

        composerView.configureButtons()
    }

    // MARK: Buttons

    func composerView(_ composerView: ComposerView, willConfigureButton button: ComposerButton) {
        if button == composerView.rightButton {
            let composerButtonAccessibilityLabel = composerView.textView.text.isEmpty
                ? ComposerView.localized(.micButtonLabel) : ComposerView.localized(.sendButtonLabel)
            button.accessibilityLabel = composerButtonAccessibilityLabel
            let image = composerView.textView.text.isEmpty
                ? ComposerAssets.micButtonImage : ComposerAssets.sendButtonImage
            button.setBackgroundImage(image, for: .normal)
        }
    }

    func composerView(_ composerView: ComposerView, event: UIEvent, eventType: UIControl.Event, happenedInButton button: ComposerButton) {
        let rightButtonIsRecordAudio = composerView.textView.text.isEmpty

        if eventType == .touchDown {
            if button === composerView.rightButton && rightButtonIsRecordAudio {
                self.composerView(composerView, didPressRecordAudioButton: button)
            }
        }

        if eventType == .touchUpInside {
            if button === composerView.rightButton && rightButtonIsRecordAudio {
                self.composerView(composerView, didReleaseRecordAudioButton: button)
            }

            if button === composerView.rightButton && !rightButtonIsRecordAudio {
                self.composerView(composerView, didPressSendButton: button)
            }

            if button === composerView.leftButton {
                self.composerView(composerView, didPressUploadButton: button)
            }
        }

        if eventType == .touchUpOutside {
            if button === composerView.rightButton && rightButtonIsRecordAudio {
                self.composerView(composerView, didReleaseRecordAudioButton: button)
            }
        }

        if [.touchDragInside, .touchDragOutside].contains(eventType), let touch = event.allTouches?.first {
            if button === composerView.rightButton {
                let first = touch.precisePreviousLocation(in: button).x
                let second = touch.location(in: button).x
                self.composerView(composerView, didDragRecordAudioButton: button, delta: second - first)
            }
        }
    }

    // MARK: Addons

    func numberOfAddons(in composerView: ComposerView, at slot: ComposerAddonSlot) -> UInt {
        switch slot {
        case .utility:
            return 1
        case .component:
            return 2
        }
    }

    func composerView(_ composerView: ComposerView, addonAt slot: ComposerAddonSlot, index: UInt) -> ComposerAddon? {
        switch slot {
        case .utility:
            return .hints
        case .component:
            switch index {
            case 0:
                return .reply
            case 1:
                return .editing
            default:
                return nil
            }
        }
    }

    func composerView(_ composerView: ComposerView, willConfigureOverlayView view: OverlayView, with userData: Any?) {
        let audioUrl = (view.subviews.first as? RecordAudioView)?.audioRecorder.url

        view.subviews.forEach {
            $0.removeFromSuperview()
        }

        if userData as? String == "RecordAudioView" {
            let recordAudioView: RecordAudioView
            if let recordAudioView_ = view.subviews.first as? RecordAudioView {
                recordAudioView = recordAudioView_
            } else {
                recordAudioView = RecordAudioView()
                recordAudioView.translatesAutoresizingMaskIntoConstraints = false
                recordAudioView.composerView = composerView
                recordAudioView.delegate = self

                view.addSubview(recordAudioView)
                view.addConstraints([
                    recordAudioView.heightAnchor.constraint(equalTo: view.heightAnchor),
                    recordAudioView.widthAnchor.constraint(equalTo: view.widthAnchor),
                    recordAudioView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    recordAudioView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }

            return
        }

        if userData as? String == "PreviewAudioView" {
            let previewAudioView: PreviewAudioView
            if let previewAudioView_ = view.subviews.first as? PreviewAudioView {
                previewAudioView = previewAudioView_
            } else {
                previewAudioView = PreviewAudioView()
                previewAudioView.translatesAutoresizingMaskIntoConstraints = false
                previewAudioView.composerView = composerView
                previewAudioView.delegate = self
                previewAudioView.audioView.audioUrl = audioUrl

                view.addSubview(previewAudioView)
                view.addConstraints([
                    previewAudioView.heightAnchor.constraint(equalTo: view.heightAnchor),
                    previewAudioView.widthAnchor.constraint(equalTo: view.widthAnchor),
                    previewAudioView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    previewAudioView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }

            return
        }
    }

    func composerView(_ composerView: ComposerView, didConfigureOverlayView view: OverlayView) {

    }

    func composerView(_ composerView: ComposerView, didUpdateAddonView view: UIView?, at slot: ComposerAddonSlot, index: UInt) {
        if let view = view as? HintsView {
            view.hintsDelegate = self
        }

        if let view = view as? ReplyView {
            view.delegate = self
        }

        if let view = view as? EditingView {
            view.delegate = self
        }
    }

    func composerView(_ composerView: ComposerView, didPressRecordAudioButton button: UIButton) {
        composerView.showOverlay(userData: "RecordAudioView")
        composerView.recordAudioView?.startRecording()
    }

    func composerView(_ composerView: ComposerView, didReleaseRecordAudioButton button: UIButton) {
        guard let view = composerView.recordAudioView else {
            return
        }

        let dismiss = view.frame.width + view.transform.tx < view.frame.width*0.75

        if dismiss {
            view.dismiss()
        } else {
            view.stopRecording()
        }
    }

    func composerView(_ composerView: ComposerView, didDragRecordAudioButton button: UIButton, delta: CGFloat) {
        guard let view = composerView.recordAudioView else {
            return
        }

        view.transform = view.transform.translatedBy(x: delta, y: 0)
    }

    func recordAudioView(_ view: RecordAudioView, didRecordAudio url: URL) {
        view.composerView?.showOverlay(userData: "PreviewAudioView")
    }

    func recordAudioViewDidCancel(_ view: RecordAudioView) {
        view.composerView?.hideOverlay()
    }

    func previewAudioView(_ view: PreviewAudioView, didConfirmAudio url: URL) {
        guard let composerView = view.composerView else {
            return
        }

        self.composerView(composerView, didFinishRecordingAudio: url)
        view.composerView?.hideOverlay()
    }

    func previewAudioView(_ view: PreviewAudioView, didDiscardAudio url: URL) {
        try? FileManager.default.removeItem(at: url)
        view.composerView?.hideOverlay()
    }
}
