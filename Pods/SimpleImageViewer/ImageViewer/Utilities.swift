import QuartzCore
import AVFoundation

struct Utilities {
    static func rect(forSize size: CGSize) -> CGRect {
        return CGRect(origin: .zero, size: size)
    }

    static func aspectFitRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: insideRect)
    }

    static func aspectFillRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        let imageRatio = size.width / size.height
        let insideRectRatio = insideRect.width / insideRect.height
        if imageRatio > insideRectRatio {
            return CGRect(x: 0, y: 0, width: floor(insideRect.height * imageRatio), height: insideRect.height)
        } else {
            return CGRect(x: 0, y: 0, width: insideRect.width, height: floor(insideRect.width / imageRatio))
        }
    }

    static func center(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    static func centerTop(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: insideSize.width / 2, y: size.height / 2)
    }
    
    static func centerBottom(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: insideSize.width / 2, y: insideSize.height - size.height / 2)
    }
    
    static func centerLeft(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: insideSize.height / 2)
    }
    
    static func centerRight(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: insideSize.width - size.width / 2, y: insideSize.height / 2)
    }
    
    static func topLeft(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    static func topRight(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: insideSize.width - size.width / 2, y: size.height / 2)
    }
    
    static func bottomLeft(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: insideSize.height - size.height / 2)
    }
    
    static func bottomRight(forSize size: CGSize, insideSize: CGSize) -> CGPoint {
        return CGPoint(x: insideSize.width - size.width / 2, y: insideSize.height - size.height / 2)
    }
}
