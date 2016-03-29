/******************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2016 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * This file is licensed to you under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 * OF ANY KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 ******************************************************************************/

import UIKit

class OnScreenCollectionViewController : BaseCollectionViewController, UIViewControllerPreviewingDelegate, PeekPanViewControllerDelegate, PeekPanCoordinatorDataSource {
    var peekPanCoordinator: PeekPanCoordinator!
    let peekPanVC = PeekPanViewController()

    var pointerView: UIView!
    var highlightedView: UIView!
    var leftView: UIView!
    var rightView: UIView!
    var panViewContainer: UIView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImages()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        panViewContainer.removeFromSuperview()
        pointerView.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDemo()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: collectionView)
                peekPanCoordinator = PeekPanCoordinator(sourceView: collectionView)
                peekPanCoordinator.delegate = peekPanVC
                peekPanCoordinator.dataSource = self
                peekPanVC.delegate = self
            }
        }
    }
    
    // MARK: Methods
    
    func setupDemo() {
        panViewContainer = UIView(frame: CGRectMake(PeekPanCoordinator.DefaultHorizontalMargin, 0.0, CGRectGetWidth(view.bounds) - 2*PeekPanCoordinator.DefaultHorizontalMargin, CGRectGetHeight(view.bounds)))
        panViewContainer.clipsToBounds = true
        panViewContainer.userInteractionEnabled = false
        panViewContainer.hidden = true
        
        highlightedView = UIView(frame: CGRectMake(0.0, 0.0, 1.0, CGRectGetHeight(view.bounds)))
        highlightedView.alpha = 0.6
        highlightedView.backgroundColor = .greenColor()
        panViewContainer.addSubview(highlightedView)
        
        leftView = UIView(frame: CGRectMake(0.0, 0.0, 1.0, CGRectGetHeight(view.bounds)))
        leftView.alpha = 0.2
        leftView.backgroundColor = .greenColor()
        panViewContainer.addSubview(leftView)
        
        rightView = UIView(frame: CGRectMake(0.0, 0.0, 1.0, CGRectGetHeight(view.bounds)))
        rightView.alpha = 0.2
        rightView.backgroundColor = .greenColor()
        panViewContainer.addSubview(rightView)
        
        pointerView = UIView(frame: CGRectMake(0.0, 0.0, 1.0, CGRectGetHeight(view.bounds)))
        pointerView.backgroundColor = .redColor()
        pointerView.hidden = true
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window {
            window.addSubview(panViewContainer)
            window.addSubview(pointerView)
        }
    }
    
    func setupImages() {
        for i in 1...4 {
            thumbnailItems.append(UIImage(named: "image" + String(i))!)
        }
    }
    
    // MARK: PeekPanCoordinatorDataSource
    
    func maximumIndex(for peekPanCoordinator: PeekPanCoordinator) -> Int {
        return thumbnailItems.count - 1
    }
    
    func shouldStartFromMinimumIndex(for peekPanCoordinator: PeekPanCoordinator) -> Bool {
        return false
    }
    
    // MARK: PeekPanControllerDelegate
    
    func peekPanCoordinatorBegan(peekPanCoordinator: PeekPanCoordinator) {
        peekPanCoordinator.startingIndex
        let startingPointInMargins = peekPanCoordinator.startingPoint.x - PeekPanCoordinator.DefaultHorizontalMargin
        
        let segmentWidth = CGRectGetWidth(panViewContainer.bounds) / CGFloat(min(thumbnailItems.count, PeekPanCoordinator.DefaultPeekRange))
        let deltaIndex = peekPanCoordinator.currentIndex - peekPanCoordinator.startingIndex
        if deltaIndex == 0 {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else if deltaIndex > 0 {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2 + CGFloat(deltaIndex)*segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2 + CGFloat(deltaIndex)*segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        if peekPanCoordinator.currentIndex != 0 {
            leftView.frame = CGRectMake(CGRectGetMinX(highlightedView.frame) - segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            leftView.frame.size.width = 0
        }
        if peekPanCoordinator.currentIndex != peekPanCoordinator.maximumIndex {
            rightView.frame = CGRectMake(CGRectGetMaxX(highlightedView.frame), 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            rightView.frame.size.width = 0
        }
        
        panViewContainer.hidden = false
        pointerView.hidden = false
    }
    
    func peekPanCoordinatorEnded(peekPanCoordinator: PeekPanCoordinator) {
        panViewContainer.hidden = true
        pointerView.hidden = true
    }
    
    func peekPanCoordinatorUpdated(peekPanCoordinator: PeekPanCoordinator) {
        pointerView.frame = CGRectMake(peekPanCoordinator.currentPoint.x, 0.0, 1.0, CGRectGetHeight(view.bounds))
        
        let startingPointInMargins = peekPanCoordinator.startingPoint.x - PeekPanCoordinator.DefaultHorizontalMargin
        
        let segmentWidth = CGRectGetWidth(panViewContainer.bounds) / CGFloat(min(thumbnailItems.count, PeekPanCoordinator.DefaultPeekRange))
        let deltaIndex = peekPanCoordinator.currentIndex - peekPanCoordinator.startingIndex
        if deltaIndex == 0 {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else if deltaIndex > 0 {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2 + CGFloat(deltaIndex)*segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            highlightedView.frame = CGRectMake(startingPointInMargins - segmentWidth/2 + CGFloat(deltaIndex)*segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        if peekPanCoordinator.currentIndex != 0 {
            leftView.frame = CGRectMake(CGRectGetMinX(highlightedView.frame) - segmentWidth, 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            leftView.frame.size.width = 0
        }
        if peekPanCoordinator.currentIndex != peekPanCoordinator.maximumIndex {
            rightView.frame = CGRectMake(CGRectGetMaxX(highlightedView.frame), 0.0, segmentWidth, CGRectGetHeight(view.bounds))
        }
        else {
            rightView.frame.size.width = 0
        }
    }
    
    // MARK: PeekPanViewControllerDelegate
    
    func view(for peekPanViewController: PeekPanViewController, atIndex index: Int) -> UIView? {
        return UIImageView(image: thumbnailItems[index])
    }
    
    // MARK: UIViewControllerPreviewingDelegate
    
    @available (iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItemAtPoint(location) else { return nil }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return nil }
        
        previewingContext.sourceRect = cell.frame
        
        peekPanCoordinator.setup(at: indexPath.item)
        
        return peekPanVC
    }
    
    @available (iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        peekPanCoordinator.end(true)
    }
}