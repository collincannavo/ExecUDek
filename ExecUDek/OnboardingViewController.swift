//
//  OnboardingViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/8/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var pageArray = [UIViewController()]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        let page1: UIViewController? = storyboard?.instantiateViewController(withIdentifier: "page1")
        let page2: UIViewController? = storyboard?.instantiateViewController(withIdentifier: "page2")
        let page3: UIViewController? = storyboard?.instantiateViewController(withIdentifier: "page3")
        
        guard let newPage1 = page1 else { return }
        guard let newPage2 = page2 else { return }
        guard let newPage3 = page3 else { return }
        
        pageArray.append(newPage1)
        pageArray.append(newPage2)
        pageArray.append(newPage3)
        
        
        setViewControllers([page1!], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
        guard let currentIndex = pageArray.index(of: viewController) else { return UIViewController() }
        
        let nextIndex = abs((currentIndex + 1) % pageArray.count)
        
        return pageArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pageArray.index(of: viewController) else { return UIViewController() }
        
        let previousIndex = abs((currentIndex - 1) % pageArray.count)
        
        return pageArray[previousIndex]
    
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
    
        return pageArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }

}
