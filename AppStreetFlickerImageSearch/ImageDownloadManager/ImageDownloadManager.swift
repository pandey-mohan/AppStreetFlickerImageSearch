//
//  ImageDownloadManager.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloadManager{
    
    static let shared = ImageDownloadManager()
    private init(){}
    let pendingOperations = PendingOperations()
    let imageCache = NSCache<NSString, UIImage>()
    
    private var completionHandler = [String : ImageDownloadCompletionHandler]()
    
    func startDownloadForRecord(photoDetails: FlikerPhoto, isThumbnail: Bool = true, completionHandler: @escaping ImageDownloadCompletionHandler){
        
        guard let thumbnailURL = photoDetails.thumbnailURL, let photoURL = photoDetails.photoURL else{return}
        
        let cachedUrl = isThumbnail ? thumbnailURL.absoluteString : photoURL.absoluteString
        self.completionHandler[cachedUrl] = completionHandler
        
        
        if let _ = pendingOperations.downloadsInProgress[cachedUrl] {
            print("already downloading the image returning ......")
            return
        }
        print("")
        
        
        if let cachedImage = imageCache.object(forKey: cachedUrl as NSString) {
            print("cached image returned")
            self.completionHandler[cachedUrl]!(cachedImage, nil)
            return
        }
        
        let downloader = ImageDownloader(photoRecord: photoDetails, isThumbnail: isThumbnail)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                
                if let _ = downloader.image{
                    self.imageCache.setObject(downloader.image!, forKey: cachedUrl as NSString)
                    self.pendingOperations.downloadsInProgress.removeValue(forKey: cachedUrl)
                    self.completionHandler[cachedUrl]!(downloader.image, nil)
                }else{
                    self.completionHandler[cachedUrl]!(nil, nil)
                }
            }
        }
        
        pendingOperations.downloadsInProgress[cachedUrl] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func cancelAllOperations(){
        pendingOperations.downloadQueue.cancelAllOperations()
        imageCache.removeAllObjects()
    }
    
    
}
