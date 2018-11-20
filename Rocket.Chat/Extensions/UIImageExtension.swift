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

    var compressedForUpload: Data {
        guard let auth = AuthManager.isAuthenticated() else { return Data() }
        guard let settings = auth.settings else { return Data() }
        let maxSize = settings.maxFileSize
        return compressedImage(forMaxExpectedSize: maxSize)
    }

    func compressedImage(forMaxExpectedSize maxSize: Int) -> Data {

        let jpegImage = self.jpegData(compressionQuality: 1.0) ?? Data()
        let imageSize = jpegImage.byteSize

        if imageSize < maxSize || maxSize <= 0 {
            return jpegImage
        }

        var percentSize = UIImage.percentSizeAfterCompression(forImageWithSize: imageSize, maxExpectedSize: maxSize)
        while true {
            let compressedImage = self.compressedImage(resizedWithPercentage: percentSize)
            if compressedImage.byteSize < maxSize || percentSize == 0.0 {
                return compressedImage
            } else if percentSize < 0.1 {
                percentSize = 0.0
            } else {
                percentSize *= 0.8
            }
        }
    }

    private func compressedImage(resizedWithPercentage percentage: CGFloat) -> Data {
        let resizedImage = self.resized(withPercentage: percentage) ?? UIImage()
        return resizedImage.jpegData(compressionQuality: 0.5) ?? Data()
    }

    private static func percentSizeAfterCompression(forImageWithSize size: Int, maxExpectedSize maxSize: Int) -> CGFloat {
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
