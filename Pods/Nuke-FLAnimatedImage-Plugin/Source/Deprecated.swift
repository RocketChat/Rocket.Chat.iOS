// The MIT License (MIT)
//
// Copyright (c) 2016-2018 Alexander Grebenyuk (github.com/kean).

import UIKit
import FLAnimatedImage
import Nuke

@available(*, deprecated, message: "GIF support is now built into default `ImageDecoder`.")
public class AnimatedImageDecoder: Nuke.DataDecoding {
    public init() {}

    public func decode(data: Data, response: URLResponse) -> Nuke.Image? {
        guard self.isAnimatedGIFData(data), let image = UIImage(data: data) else {
            return nil
        }
        image.animatedImageData = data
        return image
    }

    public func isAnimatedGIFData(_ data: Data) -> Bool {
        let sigLength = 3
        if data.count < sigLength {
            return false
        }
        var sig = [UInt8](repeating: 0, count: sigLength)
        (data as NSData).getBytes(&sig, length:sigLength)
        return sig[0] == 0x47 && sig[1] == 0x49 && sig[2] == 0x46
    }
}

@available(*, deprecated, message: "Please see README for more info.")
extension Nuke.Manager {
    /// `Nuke.Manager` with animated GIF support.
    public static let animatedImageManager: Nuke.Manager = {
        // Make a decoder which supports animated GIFs.
        let decoder = Nuke.DataDecoderComposition(decoders: [AnimatedImageDecoder(), Nuke.DataDecoder()])

        let cache = Nuke.Cache()
        cache.prepareForAnimatedImages()

        var options = Nuke.Loader.Options()
        options.prepareForAnimatedImages()

        let loader = Nuke.Loader(loader: Nuke.DataLoader(), decoder: decoder, options: options)

        return Manager(loader: loader, cache: cache)
    }()
}

@available(*, deprecated, message: "Please see README for more info.")
public class AnimatedImageView: UIView, Nuke.Target {
    public let imageView: FLAnimatedImageView

    public init(imageView: FLAnimatedImageView = FLAnimatedImageView()) {
        self.imageView = imageView

        super.init(frame: CGRect.zero)

        addSubview(imageView)

        layoutMargins = UIEdgeInsets.zero

        imageView.translatesAutoresizingMaskIntoConstraints = false
        for attr in [.top, .leading, .bottom, .trailing] as [NSLayoutAttribute] {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: attr, relatedBy: .equal, toItem: self, attribute: attr, multiplier: 1, constant: 0))
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("AnimatedImageView doesn't support NSCoding yet")
    }

    /// Displays an image on success. Runs `opacity` transition if
    /// the response was not from the memory cache.
    public func handle(response: Result<Image>, isFromMemoryCache: Bool) {
        guard let image = response.value else { return }
        imageView.nk_display(image)
        if !isFromMemoryCache {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.25
            animation.fromValue = 0
            animation.toValue = 1
            let layer: CALayer? = imageView.layer // Make compiler happy on OSX
            layer?.add(animation, forKey: "imageTransition")
        }
    }
}

@available(*, deprecated, message: "Please see README for more info.")
public extension FLAnimatedImageView {
    /// Displays a given image. Starts animation if image is an instance of AnimatedImage.
    public func nk_display(_ image: Image?) {
        display(image: image)
    }
}

@available(*, deprecated, message: "Please see README for more info.")
public extension Nuke.Loader.Options {
    /// Disables processing of animated images by setting `processor` closure.
    public mutating func prepareForAnimatedImages () {
        // Disable processing of animated images.
        processor = { image, request in
            return (image.animatedImageData != nil) ? nil : request.processor
        }
    }
}

@available(*, deprecated, message: "Please see README for more info.")
public extension Nuke.Cache {
    /// Updates `Cache` cost block by adding special handling of `AnimatedImage`.
    public func prepareForAnimatedImages() {
        let cost = self.cost
        self.cost = {
            guard let data = $0.animatedImageData else {
                return cost($0) // Simply return default cost.
            }
            return cost($0) + data.count // Return cost + animated image data size.
        }
    }
}
