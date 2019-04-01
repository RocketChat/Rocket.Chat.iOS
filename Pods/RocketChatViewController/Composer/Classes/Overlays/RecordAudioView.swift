//
//  RecordAudioView.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 07/01/2019.
//

import UIKit
import AVFoundation

public protocol RecordAudioViewDelegate: class {
    func recordAudioView(_ view: RecordAudioView, didRecordAudio url: URL)
    func recordAudioViewDidCancel(_ view: RecordAudioView)
}

public class RecordAudioView: UIView {
    public weak var composerView: ComposerView?
    public weak var delegate: RecordAudioViewDelegate?

    public var soundFeedbacksPlayer: AVAudioPlayer?

    internal let feedbackNotification = UINotificationFeedbackGenerator()

    public let audioRecorder = AudioRecorder()

    public var timer: Timer?

    public var time: TimeInterval = 0 {
        didSet {
            let minutes = Int(time) / 60
            let seconds = time - Double(minutes) * 60
            timeLabel.text = String(format: "%01i:%02i", minutes, Int(seconds))
        }
    }

    public let timeLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "0:00"
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.textColor = #colorLiteral(red: 0.9607843137, green: 0.2705882353, blue: 0.3607843137, alpha: 1)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    public let swipeIndicatorView = tap(SwipeIndicatorView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    public let micButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 40),
            $0.heightAnchor.constraint(equalToConstant: 40)
        ])

        $0.setBackgroundImage(ComposerAssets.redMicButtonImage, for: .normal)
        $0.addTarget(self, action: #selector(touchUpInsideMicButton), for: .touchUpInside)
    }

    override public var intrinsicContentSize: CGSize {
        let maxHeight = max(timeLabel.intrinsicContentSize.height, micButton.bounds.height)
        let height = isHidden ? 0 : layoutMargins.top + maxHeight + layoutMargins.bottom

        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let translationX = swipeIndicatorView.intrinsicContentSize.width + 43 + micButton.intrinsicContentSize.width

        swipeIndicatorView.transform = CGAffineTransform(translationX: translationX, y: 0)
        micButton.transform = CGAffineTransform(translationX: translationX, y: 0)
        timeLabel.alpha = 0

        UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction, animations: {
            self.swipeIndicatorView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.micButton.transform = CGAffineTransform(translationX: 0, y: 0)
            self.timeLabel.alpha = 1
        }, completion: nil)
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
        backgroundColor = .white
        clipsToBounds = true

        audioRecorder.delegate = self

        timer = .scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true
        )

        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
        addGestureRecognizers()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(timeLabel)
        addSubview(swipeIndicatorView)
        addSubview(micButton)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            swipeIndicatorView.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -43),
            swipeIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            micButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -11),
            micButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /**
     Adds the required gesture recognizers.
     */
    private func addGestureRecognizers() {
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognized))
        swipeRecognizer.direction = .left
        swipeIndicatorView.addGestureRecognizer(swipeRecognizer)
    }

    /**
     Starts recording
     */
    func startRecording() {
        if !audioRecorder.isRecording {
            feedbackNotification.notificationOccurred(.warning)

            if let startAudioRecordURL = ComposerAssets.startAudioRecordSound {
                play(sound: startAudioRecordURL)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.audioRecorder.record()
            }
        }
    }

    /**
     Stops recording
     */
    func stopRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stop()
            self.feedbackNotification.notificationOccurred(.success)
        }
    }

    /**
     Dismisses the view
     */
    func dismiss() {
        if let cancelAudioRecordURL = ComposerAssets.cancelAudioRecordSound {
            play(sound: cancelAudioRecordURL)
        }

        self.feedbackNotification.notificationOccurred(.success)

        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(translationX: -self.frame.width, y: 0)
        }) { _ in
            self.audioRecorder.delegate = nil
            self.audioRecorder.cancel()
            self.delegate?.recordAudioViewDidCancel(self)
        }
    }

    /**
     Play UI feedback sound
     */
    func play(sound: URL) {
        do {
            soundFeedbacksPlayer = try AVAudioPlayer(contentsOf: sound, fileTypeHint: AVFileType.m4a.rawValue)
            soundFeedbacksPlayer?.play()
        } catch _ {
            // Ignore the error
        }
    }
}

// MARK: AVAudioRecorderDelegate

extension RecordAudioView: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.recordAudioView(self, didRecordAudio: recorder.url)
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

    }

    public func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {

    }

    public func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {

    }
}

// MARK: Events

extension RecordAudioView {
    @objc func timerTick() {
        if audioRecorder.isRecording {
            time += 0.5
        } else {
            time = 0
        }
    }

    @objc func touchUpInsideMicButton() {
        if !audioRecorder.isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }

    @objc func swipeRecognized() {
        dismiss()
    }
}

// MARK: SwipeIndicatorView

public class SwipeIndicatorView: UIView, ComposerLocalizable {
    public let imageView = tap(UIImageView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = ComposerAssets.grayArrowLeftButtonImage

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: Consts.imageViewWidth),
            $0.heightAnchor.constraint(equalToConstant: Consts.imageViewHeight)
        ])
    }

    public let label = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = localized(.swipeIndicatorViewTitle)
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = #colorLiteral(red: 0.6196078431, green: 0.6352941176, blue: 0.6588235294, alpha: 1)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    override public var intrinsicContentSize: CGSize {
        let maxHeight = max(label.intrinsicContentSize.height, imageView.bounds.height)
        let height = isHidden ? 0 : layoutMargins.top + maxHeight + layoutMargins.bottom

        return CGSize(width: imageView.intrinsicContentSize.width + Consts.imageViewTrailing + label.intrinsicContentSize.width, height: height)
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
        addSubview(imageView)
        addSubview(label)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: Consts.imageViewTrailing),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    struct Consts {
        static let imageViewWidth: CGFloat = 24
        static let imageViewHeight: CGFloat = 24
        static let imageViewTrailing: CGFloat = 2
    }
}
