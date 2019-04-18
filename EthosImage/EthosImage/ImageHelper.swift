//
//  ImageHelper.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

typealias ImageCache = LRUCache<String, MediaResource>

open class ImageHelper {
    
    // MARK: - Constructor
    fileprivate init() {
        MediaDescriptor.Source.array.forEach { (source) in
            if self.getCache(source: source) != nil {
                return
            }
            
            let key = self.getCacheKey(source: source)
            
            let lock = Lock()
            locks.set(key, lock)
            
            let cache = ImageCache(cacheName: self.getCacheName(source: source),
                                   totalCost: self.getCacheSize(source: source))
            cache.load()
            caches.set(key, cache)
        }
    }
    
    public static let shared = ImageHelper()
    
    // MARK: - State Variables
    fileprivate var caches = [String: ImageCache]()
    
    fileprivate var locks = [String: Lock]()
    
    fileprivate var bundles = Set<Bundle>()
    
    // MARK: - Cache Methods
    fileprivate func getCacheKey(source: MediaDescriptor.Source) -> String {
        switch (source) {
        case .Http, .Https:
            return "web"
        default:
            return source.rawValue
        }
    }
    
    fileprivate func getCacheName(source: MediaDescriptor.Source) -> String {
        return "\(getCacheKey(source: source))_image_cache"
    }
    
    fileprivate func getCacheSize(source: MediaDescriptor.Source) -> Int {
        switch (source) {
        case .Http, .Https:
            return 100 * 1024 * 1024
        default:
            return 50 * 1024 * 1024
        }
    }
    
    fileprivate func getCache(source: MediaDescriptor.Source) -> ImageCache? {
        return self.caches.get(self.getCacheKey(source: source))
    }
    
    open func setCacheSize(source: MediaDescriptor.Source, bytes: Int) {
        self.getCache(source: source)?.totalCost = bytes
    }
    
    // MARK: Bundle Methods
    open func getAvailablesBundles() -> [Bundle] {
        return Array(self.bundles)
    }
    
    open func addBundle(_ bundle: Bundle) {
        self.bundles.insert(bundle)
    }
    
    open func removeBundle(_ bundle: Bundle) {
        self.bundles.remove(bundle)
    }
    
    //MARK: - Queue Variables -
    /**
     This queue handles getting images from the web, it allows 5 unique requests at once
     */
    private let uriQueue = UniqueOperationQueue<MediaResource>(name: "image.queue.uri", concurrentCount: 10)
    
    /**
     This queue handles getting images from the bundle and filesystem, it allows 5 unique requests at once
     */
    private let fileSystemQueue = UniqueOperationQueue<MediaResource>(name: "image.queue.filesystem", concurrentCount: 10)
    
    // MARK: - Cache Methods -
    fileprivate func getFromCache(key: String, source: MediaDescriptor.Source) -> MediaResource? {
        return self.getCache(source: source)?.get(key: key, synchronize: true)
    }
    
    fileprivate func fetch(mediaDescriptor: MediaDescriptor, cached: MediaResource?,
                           callback: @escaping (MediaResource?) -> Void) {
        switch (mediaDescriptor.source) {
        case .Https, .Http:
            let op = GetUriResource(url: mediaDescriptor.key).with(mediaResource: cached)
            uriQueue.addOperation(op: op, callback: callback)
        case .Asset:
            let op = GetFileResource(uri: mediaDescriptor.key).with(mediaResource: cached)
            fileSystemQueue.addOperation(op: op, callback: callback)
        default:
            callback(nil)
            break
        }
    }
    
    open func get(mediaDescriptor: MediaDescriptor, callback: @escaping (MediaResource?) -> Void) {
        ThreadHelper.background {
            let cachedResource = self.getFromCache(key: mediaDescriptor.transformedKey,
                                                   source: mediaDescriptor.source)
            
            if cachedResource != nil {
                cachedResource?.source = .cache
                callback(cachedResource)
            }
            
            self.fetch(mediaDescriptor: mediaDescriptor, cached: cachedResource) { (mr: MediaResource?) in
                guard let mediaResource = mr else {
                    callback(mr)
                    return
                }
                
                if mediaResource.isEqual(cachedResource) {
                    return
                }
                
                if mediaDescriptor.hasTransfroms, let transformedImage = mediaDescriptor.transform(image: mediaResource.image) {
                    mediaResource.data = transformedImage.jpegData(compressionQuality: 1)
                    mediaResource.contentType = "image/jpeg"
                }
                
                let cache = self.getCache(source: mediaDescriptor.source)
                cache?.put(key: mediaDescriptor.transformedKey, value: mediaResource, cost: mediaResource.getCost())
                
                switch (mediaDescriptor.source) {
                case .Http, .Https:
                    mediaResource.source = MediaResource.Source.web
                default:
                    mediaResource.source = MediaResource.Source.bundle
                }
            
                callback(mediaResource)
            }
        }
    }
    
    /**
     Synchronously get a set of images responses
     - parameter requests: A list of requests describing images and transforms
     */
    open func get(requests: [MediaDescriptor]) -> [MediaResource?] {
        return TaskManager<MediaDescriptor, MediaResource>(values: requests)
            .with(asyncHandler: { self.get(mediaDescriptor: $0, callback: $1) })
            .sync(timeout: 120)
    }
    
    /**
     Synchronously get a set of images without any transforms
     - parameter urls: A list of resource urls
     */
    open func get(urls: [String]) -> [UIImage?] {
        let requests = urls.compactMap() { MediaDescriptor(resource: $0) }
        let responses = self.get(requests: requests)
        return responses.map() { $0?.image }
    }
    
    
    // MARK: - Cleanup Methods -
    
    /**
     Save current snapshot
     */
    open func save() {
        self.caches.forEach { $1.save() }
    }
    
    /**
     Save snapshot stored on the filesystem
     */
    open func deleteCachedData() {
        self.caches.forEach { $1.delete() }
    }
}

