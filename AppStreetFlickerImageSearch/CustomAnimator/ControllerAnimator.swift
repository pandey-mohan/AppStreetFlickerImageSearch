//
//  ControllerAnimator.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import UIKit

class ControllerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    let duration = 0.3
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let photoView = presenting ? toView :
            transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : photoView.frame
        let finalFrame = presenting ? photoView.frame : originFrame
        
        let xScaleFactor = presenting ?
            
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        
        if presenting {
            photoView.transform = scaleTransform
            photoView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            photoView.clipsToBounds = true
        }
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(photoView)
        UIView.animate(withDuration: duration, delay:0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                       animations: {
                        photoView.transform = self.presenting ?
                            CGAffineTransform.identity : scaleTransform
                        photoView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        },
                       completion: { _ in
                        if !self.presenting {
                            self.dismissCompletion?()
                        }
                        transitionContext.completeTransition(true)
        }
        )
    }
}
