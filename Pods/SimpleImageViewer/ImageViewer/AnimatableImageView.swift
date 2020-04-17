import UIKit

final class AnimatableImageView: UIView {
    fileprivate let imageView = UIImageView()
    
    override var contentMode: UIView.ContentMode {
        didSet { update() }
    }
    
    override var frame: CGRect {
        didSet { update() }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            update()
        }
    }
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(imageView)
        imageView.contentMode = .scaleToFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AnimatableImageView {
    func update() {
        guard let image = image else { return }
        
        switch contentMode {
        case .scaleToFill:
            imageView.bounds = Utilities.rect(forSize: bounds.size)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .scaleAspectFit:
            imageView.bounds = Utilities.aspectFitRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .scaleAspectFill:
            imageView.bounds = Utilities.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .redraw:
            imageView.bounds = Utilities.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .center:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .top:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerTop(forSize: image.size, insideSize: bounds.size)
        case .bottom:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerBottom(forSize: image.size, insideSize: bounds.size)
        case .left:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerLeft(forSize: image.size, insideSize: bounds.size)
        case .right:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerRight(forSize: image.size, insideSize: bounds.size)
        case .topLeft:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.topLeft(forSize: image.size, insideSize: bounds.size)
        case .topRight:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.topRight(forSize: image.size, insideSize: bounds.size)
        case .bottomLeft:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.bottomLeft(forSize: image.size, insideSize: bounds.size)
        case .bottomRight:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.bottomRight(forSize: image.size, insideSize: bounds.size)
        }
    }
}
