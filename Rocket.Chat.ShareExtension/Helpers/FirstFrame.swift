//
//  VideoFrame.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import AVFoundation
import UIKit

func firstFrame(videoURL: URL) -> UIImage? {
    let asset = AVURLAsset(url: videoURL, options: nil)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true

    guard let cgImage = try? generator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil) else {
        return nil
    }

    return UIImage(cgImage: cgImage)
}
