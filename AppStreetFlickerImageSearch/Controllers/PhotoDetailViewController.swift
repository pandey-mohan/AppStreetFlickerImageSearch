//
//  PhotoDetailViewController.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPhotoDetail()
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var photoTitle: UILabel!
    
    var photoRecordTupel: (FlikerPhoto, IndexPath)?
    
    
    func setupPhotoDetail(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PhotoDetailViewController.actionClose(_:))))
        
        if let photoTupel = photoRecordTupel{
            
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.photoTitle.text = photoTupel.0.title
            }
            
            ImageDownloadManager.shared.startDownloadForRecord(photoDetails: photoTupel.0,isThumbnail: false, completionHandler: { (image, error) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.indicator.stopAnimating()
                }
            })
        }
    }
    
    @objc func actionClose(_ tap: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
}

