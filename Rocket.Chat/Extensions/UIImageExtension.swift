//
//  UIImageExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/16/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIImage {

    func imageWithTint(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        guard let cgImage = cgImage else { return self }

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        let context = UIGraphicsGetCurrentContext()

        color.setFill()

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        context?.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context?.draw(cgImage, in: rect)

        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = img else { return self }
        return image
    }

    func resizeWith(width: CGFloat) -> UIImage? {
        let height = CGFloat(ceil(width/self.size.width * self.size.height))
        let size = CGSize(width: width, height: height)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()

        return result
    }

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        if percentage == 1.0 { return self }

        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func compressForUpload() -> Data {
        guard let auth = AuthManager.isAuthenticated() else { return Data() }
        guard let settings = auth.settings else { return Data() }
        let maxSize = settings.maxFileSize
        return compressImage(forMaxExpectedSize: maxSize)
    }

    func compressImage(forMaxExpectedSize maxSize: Int) -> Data {

        let jpegImage = UIImageJPEGRepresentation(self, 1.0) ?? Data()
        let imageSize = jpegImage.byteSize

        if imageSize < maxSize {
            return jpegImage
        }

        var percentSize = percentSizeAfterCompression(forImageWithSize: imageSize, maxExpectedSize: maxSize)
        while true {
            let compressedImage = compressImage(resizedWithPercentage: percentSize)
            if compressedImage.byteSize < maxSize {
                return compressedImage
            } else {
                percentSize *= 0.8
            }
        }
    }

    private func compressImage(resizedWithPercentage percentage: CGFloat) -> Data {
        let resizedImage = self.resized(withPercentage: percentage) ?? UIImage()
        return UIImageJPEGRepresentation(resizedImage, 0.5) ?? Data()
    }

    private func percentSizeAfterCompression(forImageWithSize size: Int, maxExpectedSize maxSize: Int) -> CGFloat {
        let sizeReductionFactor: CGFloat = 0.36
        let safeEstimationFactor: CGFloat = 0.95

        let expectedImageSizeOnCompression = CGFloat(size) * sizeReductionFactor
        if expectedImageSizeOnCompression < CGFloat(maxSize) {
            return 1.0
        } else {
            return safeEstimationFactor * CGFloat(maxSize) / expectedImageSizeOnCompression
        }
    }
}
