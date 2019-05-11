//
//  ImageOperations.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState: Int, Codable {
    
    case New, Downloaded, Failed
}

typealias ImageDownloadCompletionHandler = (UIImage?, Error?) -> Void



class PendingOperations {
    lazy var downloadsInProgress = [String:Operation]()
    
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        return queue
    }()
}

class ImageDownloader: Operation {
    
    var photoRecord: FlikerPhoto
    var image: UIImage?
    //let completionHandler: ImageDownloadCompletionHandler
    var isThumbnail: Bool
    init(photoRecord: FlikerPhoto, isThumbnail: Bool) {
        self.photoRecord = photoRecord
        self.isThumbnail = isThumbnail
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        guard let thumbnailURL = self.photoRecord.thumbnailURL, let photoURL = self.photoRecord.photoURL else{return}
        
        
        let imageData = isThumbnail ? try? Data(contentsOf: thumbnailURL) : try? Data(contentsOf: photoURL)
        
        if self.isCancelled {
            return
        }
        
        if imageData?.count ?? 0 > 0 {
            self.image = UIImage(data:imageData!)
            self.photoRecord.state = .Downloaded
        }
        else
        {
            self.photoRecord.state = .Failed
            //self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}

class CommonMethod{
    
    class func addNativeAlertView(for viewController:UIViewController,title:String,message:String, okAction:((UIAlertAction) -> Void)?, cancelAction:((UIAlertAction) -> Void)?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okAction))
        viewController.present(alert, animated: true)
    }
}


