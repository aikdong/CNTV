//
//  PageAVPlayerController.swift
//  COCNTV
//
//  Created by Don on 6/30/16.
//  Copyright © 2016 dongxing. All rights reserved.
//

import UIKit

class PageAVPlayerController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var urls: [NSURL]!
    var pageIndex: Int = 0
    
    init(urls: [NSURL]!) {
        self.urls = urls;
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        let playerController = AVPlayerController(url: self.urls[0])
        self.setViewControllers([playerController] as [UIViewController], direction: .Forward, animated: false) { (finish) in
            playerController.player.play()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        if let currentViewController = pendingViewControllers[0] as? AVPlayerController {
            print("Pending: \(currentViewController.url)")
            currentViewController.player.play()
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Pause all
        for previousViewController in previousViewControllers {
            if let currentViewController = previousViewController as? AVPlayerController {
                currentViewController.player.pause()
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        if pageIndex > 0 {
            pageIndex -= 1;
            print("Before: \(pageIndex), count:\(self.urls.count)")
            return AVPlayerController(url: self.urls[pageIndex])
        }
        return nil;
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        if pageIndex < self.urls.count - 1 {
            pageIndex += 1;
            print("After: \(pageIndex), count:\(self.urls.count)")
            return AVPlayerController(url: self.urls[pageIndex])
        }
        return nil;
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.urls.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int{
        return pageIndex
    }
}
