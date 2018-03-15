//
//  FirstVideoFrame.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import AVFoundation
import UIKit

struct VideoInfo {
    let thumbnail: UIImage
    let duration: Double

    var durationText: String {
        let duration = Int(self.duration)
        let minutes: Int = duration/60
        let hours: Int = minutes/60
        let seconds: Int = duration%60

        return " ▶ " + ((hours < 10) ? "0" : "") + "\(hours):" + ((minutes < 10) ? "0" : "") + "\(minutes):" + ((seconds < 10) ? "0" : "") + "\(seconds) "
    }

    init?(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        guard let cgImage = try? generator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil) else {
            return nil
        }

        self.thumbnail = UIImage(cgImage: cgImage)
        self.duration = Double(CMTimeGetSeconds(asset.duration))
    }
}
