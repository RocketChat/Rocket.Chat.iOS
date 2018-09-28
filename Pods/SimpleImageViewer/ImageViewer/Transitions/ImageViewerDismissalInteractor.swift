import UIKit

final class ImageViewerDismissalInteractor: NSObject, UIViewControllerInteractiveTransitioning {
    fileprivate let transition: ImageViewerDismissalTransition
    
    init(transition: ImageViewerDismissalTransition) {
        self.transition = transition
        super.init()
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transition.start(transitionContext)
    }
    
    func update(transform: CGAffineTransform) {
        transition.update(transform: transform)
    }
    
    func update(percentage: CGFloat) {
        transition.update(percentage: percentage)
    }
    
    func cancel() {
        transition.cancel()
    }
    
    func finish() {
        transition.finish()
    }
}
