//
//  GetFileResource.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

class GetFileResource: UniqueOperation {
    
    // MARK: - Builders & Constructors
    convenience init(uri: String) {
        self.init()
        self.uri = uri
    }
    
    @discardableResult func with(mediaResource: MediaResource?) -> GetFileResource {
        self.mediaResource = mediaResource
        return self
    }
    
    // MARK: - State variables
    private var uri: String?
    
    private var mediaResource: MediaResource?
    
    // MARK: - Parent Methods -
    override func getUniqueId() -> String? {
        return self.uri
    }
    
    override func run() {
        guard let uri = self.uri, !uri.isEmpty else {
            complete(mediaResource: nil); return
        }
        handle(uri: uri)
    }
    
    // MARK: - Helper Methods
    private func addContentType(type: String, mediaResource: MediaResource) {
        switch (type) {
        case "jpg":
            mediaResource.contentType = "image/jpeg"
        default:
            break
        }
    }
    
    private func handle(uri: String) {
        guard let (resourceName, type) = uri.getFileParts() else {
            guard let image = UIImage(named: uri) else {
                complete(mediaResource: nil); return
            }
            
            let mediaResource = MediaResource()
            mediaResource.data = image.jpegData(compressionQuality: 1)
            self.addContentType(type: "jpg", mediaResource: mediaResource)
            complete(mediaResource: mediaResource)
            return
        }
        
        guard let fileHandle = defaultHandler(resourceName: resourceName, type: type) else {
            complete(mediaResource: nil); return
        }
        
        let mediaResource = MediaResource()
        
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: fileHandle.filePath)
            if let date = attrs.get(FileAttributeKey.creationDate) as? Date {
                mediaResource.lastModified = date.toString()
            }
        } catch {
            
        }
        
        if mediaResource.isEqual(self.mediaResource) {
            complete(mediaResource: self.mediaResource); return // resource has not changed, do not update
        }
        
        mediaResource.data = fileHandle.getData()
        self.addContentType(type: type, mediaResource: mediaResource)
        complete(mediaResource: mediaResource)
    }
    
    private func complete(mediaResource: MediaResource?) {
        self.deactivate(result: mediaResource)
    }
    
    private func defaultHandler(resourceName: String, type: String) -> FileSystemReference? {

        // Check the main bundle first
        if let fh = FileSystemHelper.shared.getBundleFileSystemReference(resourceName: resourceName, type: type) {
            return fh
        }

        // Check other registered bundles
        for bundle in ImageHelper.shared.getAvailablesBundles() {
            let fileSystemHelper = FileSystemHelper()
            fileSystemHelper.bundle = bundle
            if let fh = fileSystemHelper.getBundleFileSystemReference(resourceName: resourceName, type: type) {
                return fh
            }
        }

        // Check the file system
        if let fh = FileSystemHelper.shared.getFileSystemFileSystemReference(resourceName: resourceName, type: type),
            fh.fileExists {
            return fh
        }

        return nil
    }
    
}
