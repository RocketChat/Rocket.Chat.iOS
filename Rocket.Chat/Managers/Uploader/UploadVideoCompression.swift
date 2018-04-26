//
//  UploadVideoCompression.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 22/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation

public typealias CompressionCompletionBlock = (NSData?, Bool) -> Void

struct UploadVideoCompression {

    static func toMediumQuality(sourceAsset: AVURLAsset, completion: @escaping CompressionCompletionBlock) {
        let newPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mergeVideo\(arc4random()%1000)d").appendingPathExtension("mp4").absoluteString
        if FileManager.default.fileExists(atPath: newPath) {
            do {
                try FileManager.default.removeItem(atPath: newPath)
            } catch {
                return completion(nil, true)
            }
        }

        guard let newPathURL = URL(string: newPath) else { return completion(nil, true) }
        guard let assetExport: AVAssetExportSession = AVAssetExportSession(asset: sourceAsset, presetName: AVAssetExportPresetPassthrough) else { return completion(nil, true) }
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = newPathURL
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case .completed:
                do {
                    let newVideoData = try NSData(contentsOf: newPathURL, options: NSData.ReadingOptions())
                    return completion(newVideoData, false)
                } catch {
                    return completion(nil, true)
                }
            default:
                return completion(nil, true)
            }
        }

    }

}
