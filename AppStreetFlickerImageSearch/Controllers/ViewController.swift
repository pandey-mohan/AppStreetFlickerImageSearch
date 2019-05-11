//
//  ViewController.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController,CellNumber {
    
    
    
    let searchBar = UISearchBar()
    var numberSelectionView = CellNumbers()
    let perPage:Int = 40
    var searchText = String()
    var pageNumber = 1
    var footerView:CustomFooterView?
    var isLoading:Bool = false
    let footerViewReuseIdentifier = "RefreshFooterView"
    let transition = ControllerAnimator()
    var photos = [FlikerPhoto]()
    var selectedIndexPath: IndexPath?
    var cellDataArray = 12
    private let client = FlickerImagesClient()
    
    //
    var activityIndicator = UIActivityIndicatorView()
    
    
    @IBOutlet weak var centerLoader: UIActivityIndicatorView!
    @IBOutlet weak var flikrPicturesCollectionView: UICollectionView!
    
    
    @IBAction func btnOptionsTapped(_ sender: Any) {
        if view.subviews.contains(numberSelectionView){
            numberSelectionView.removeFromSuperview()
            return
        }
        numberSelectionView = Bundle.main.loadNibNamed("CellNumbers", owner: nil, options: nil)?[0] as! CellNumbers
        numberSelectionView.delegate = self
        numberSelectionView.initTableView()
        numberSelectionView.frame = CGRect(x: UIScreen.main.bounds.width-220, y: (self.navigationController?.navigationBar.bounds.height)! + 20, width: 200, height: 200)
        self.view.addSubview(numberSelectionView)
    }
    
    func sendNumberofcolumns(col: Int) {
        collectionViewLayout(for: CGFloat(col))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flikrPicturesCollectionView.dataSource = self
        flikrPicturesCollectionView.delegate = self
        
        addSearchBar()
        collectionViewLayout(for: 4)
        self.flikrPicturesCollectionView.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
        transition.dismissCompletion = {
            guard let indexPath = self.selectedIndexPath else{return}
            if let cell = self.flikrPicturesCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell{
                cell.flikrImage.isHidden = false
            }
        }
    }
    
    func callFlikerAPI(with text: String){
        centerLoader.startAnimating()
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=108ffda974ce16569058ea532d66d636&tags=\(text)&per_page=\(perPage)&page=\(pageNumber)&format=json&nojsoncallback=1")!
        let flikerFeed = FlickerFeed(url: url, httpMethod: "GET")
        
        client.getFeed(from: flikerFeed) { [weak self] result in
            DispatchQueue.main.async {
                self?.centerLoader.stopAnimating()
                switch result {
                case .success(let flikerFeedResult):
                    guard let photosArray = flikerFeedResult?.photos.photo else{
                        self?.showAlert()
                        return
                    }
                    
                    if photosArray.count < 1{
                        self?.showAlert()
                    }
                    self?.photos += photosArray
                    self?.isLoading = false
                    self?.flikrPicturesCollectionView.reloadData()
                    
                    print("API Parsing RESULT : \(photosArray)")
                    
                    
                case .failure(let error):
                    print("the error \(error)")
                    self?.showAlert()
                }
            }
        }
    }
    
    
    func showAlert(){
        
        
        DispatchQueue.main.async {
            let message: String
            if self.pageNumber > 1{
                message = "No more images found for your search."
                self.isLoading = false
                self.flikrPicturesCollectionView.reloadData()
            }else{
                message = "No images found for your search. Please try with another keyword."
                self.searchBar.text = nil
                self.searchText = ""
            }
            CommonMethod.addNativeAlertView(for: self, title: "No Images Found", message: message, okAction: nil, cancelAction: nil)
        }
    }
    
    func addSearchBar(){
        searchBar.placeholder = "Enter to search images!"
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    
    
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    
    func suspendAllOperations () {
        ImageDownloadManager.shared.pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        ImageDownloadManager.shared.pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells () {
        
        
        let pathsArray = flikrPicturesCollectionView.indexPathsForVisibleItems.map{photos[$0.row].thumbnailURL?.absoluteString ?? ""}
        
        let allPendingOperations = Set(ImageDownloadManager.shared.pendingOperations.downloadsInProgress.keys)
        
        var decreasePriority = allPendingOperations
        let visiblePaths = Set(pathsArray)
        decreasePriority.subtract(visiblePaths)
        var toBeStarted = visiblePaths
        toBeStarted.subtract(allPendingOperations)
        var increasePriority = visiblePaths
        increasePriority.subtract(toBeStarted)
        for url in decreasePriority {
            print("priority decreases")
            if let pendingDownload = ImageDownloadManager.shared.pendingOperations.downloadsInProgress[url] {
                pendingDownload.queuePriority = .veryLow
            }
        }
        
        for url in increasePriority {
            print("priority increases")
            if let pendingDownload = ImageDownloadManager.shared.pendingOperations.downloadsInProgress[url] {
                pendingDownload.queuePriority = .veryHigh
            }
        }
        
        for url in toBeStarted {
            print("Started new downloads")
            let photoDetails = self.photos.filter{$0.thumbnailURL?.absoluteString == url}
            
            if photoDetails.count == 1{
                if let index = photos.index(of: photoDetails[0]){
                    ImageDownloadManager.shared.startDownloadForRecord(photoDetails: photoDetails[0], completionHandler: { (image, error) in
                        if let cell = self.flikrPicturesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ImageCollectionViewCell{
                            DispatchQueue.main.async {
                                cell.flikrImage.image = image
                                cell.indicator.stopAnimating()
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    
    
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
        print("pullRation:\(pullRatio)")
    }
    
    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        loadImagesForOnscreenCells()
        resumeAllOperations()
        
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = abs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight <= 0.2
        {
            if (self.footerView?.isAnimatingFinal)! {
                print("load more trigger")
                self.isLoading = true
                self.footerView?.startAnimate()
                self.pageNumber+=1
                self.callFlikerAPI(with: searchText)
            }
        }
    }
    
    
}


extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let indexPath = selectedIndexPath else{return nil}
        
        guard let attributes = flikrPicturesCollectionView.layoutAttributesForItem(at: indexPath) else{return nil}
        let cellFrame = flikrPicturesCollectionView.convert(attributes.frame, to: flikrPicturesCollectionView.superview)
        transition.originFrame = cellFrame
        transition.presenting = true
        if let cell = flikrPicturesCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell{
            cell.flikrImage.isHidden = true
        }
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}



extension ViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        ImageDownloadManager.shared.cancelAllOperations()
        photos.removeAll()
        pageNumber = 1
        searchText = searchBar.text!
        flikrPicturesCollectionView.reloadData()
        //API Call
        callFlikerAPI(with: searchBar.text!)
        searchBar.endEditing(true)
    }
}

extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = flikrPicturesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        
        cell.flikrImage.image = UIImage(named: "Placeholder")
        cell.indicator.startAnimating()
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoDetails = photos[indexPath.row]
        ImageDownloadManager.shared.startDownloadForRecord(photoDetails: photoDetails, completionHandler: { (image, error) in
            DispatchQueue.main.async {
                if let cell = self.flikrPicturesCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell{
                    cell.flikrImage.image = image
                    cell.indicator.stopAnimating()
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if view.subviews.contains(numberSelectionView){
            numberSelectionView.removeFromSuperview()
        }
        let photoDetailController = storyboard!.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
        photoDetailController.photoRecordTupel = (photos[indexPath.row], indexPath)
        photoDetailController.transitioningDelegate = self
        present(photoDetailController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CustomFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionViewLayout(for numbers:CGFloat){
        let cellSize = UIScreen.main.bounds.width/numbers - 10
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionViewLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        collectionViewLayout.minimumLineSpacing = 5
        collectionViewLayout.minimumLineSpacing = 5
        
        //Animate Layouting
        UIView.animate(withDuration: 0.5,
                       delay: 0.1,
                       options: UIView.AnimationOptions.beginFromCurrentState,
                       animations: { () -> Void in
                        self.flikrPicturesCollectionView.collectionViewLayout = collectionViewLayout
        }, completion: { (finished) -> Void in
        })
    }
}
