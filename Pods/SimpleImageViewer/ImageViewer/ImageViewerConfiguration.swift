import Foundation
import FLAnimatedImage
import UIKit

public typealias ImageCompletion = (UIImage?, FLAnimatedImage?) -> Void
public typealias ImageBlock = (@escaping ImageCompletion) -> Void

public final class ImageViewerConfiguration {
    public var allowSharing: Bool = false
    public var image: UIImage?
    public var animatedImage: FLAnimatedImage?
    public var imageView: FLAnimatedImageView?
    public var imageBlock: ImageBlock?
    
    public typealias ConfigurationClosure = (ImageViewerConfiguration) -> ()
    
    public init(configurationClosure: ConfigurationClosure) {
        configurationClosure(self)
    }
}
