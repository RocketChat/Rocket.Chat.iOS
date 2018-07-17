//
//  ImageManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Nuke

struct ImageManager {

    // On older versions this name was defined internally by Nuke,
    // now that we must define it, if we don't want the people to clear the entire image caching
    // when they update the app, we must set the same data cache name that it used to be when internally managed.
    static internal let dataCacheName = "com.github.kean.Nuke.DataCache"

    static let loadingOptions: ImageLoadingOptions = {
        var loadingOptions = ImageLoadingOptions.shared
        loadingOptions.pipeline = ImageManager.pipeline
        return loadingOptions
    }()

    static let dataCache: DataCache? = {
        return try? DataCache(name: dataCacheName, filenameGenerator: {
            return $0.sha256()
        })
    }()

    static let memoryCache: ImageCache = {
        return ImageCache()
    }()

    static let pipeline = ImagePipeline {
        $0.dataLoader = DataLoader(configuration: {
            // Disable disk caching built into URLSession
            let conf = DataLoader.defaultConfiguration
            conf.urlCache = nil
            return conf
        }())

        $0.imageCache = memoryCache
        $0.dataCache = dataCache
        $0.isDeduplicationEnabled = false
    }

    @discardableResult
    static func loadImage(with url: URL, options: ImageLoadingOptions = ImageManager.loadingOptions, into view: ImageDisplayingView, progress: ImageTask.ProgressHandler? = nil, completion: ImageTask.Completion? = nil) -> ImageTask? {
        var options = options
        options.pipeline = pipeline
        return Nuke.loadImage(with: url, options: options, into: view, progress: progress, completion: completion)
    }
}
