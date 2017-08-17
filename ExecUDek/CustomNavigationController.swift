//
//  CustomNavigationController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/6/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import NotificationCenter
import SharedExecUDek

class CustomNavigationController: UINavigationController {
    
    let multipeerToolbar = UIToolbar()
    var wirelessBarButtonItem: UIBarButtonItem!
    var statusBarButtonItem: UIBarButtonItem!
    
    var pageViewController: UIPageViewController!
    
    var cardsSceneController: CardsViewController!
    var personalCardsSceneController: UserProfileCollectionViewController!
    
    var index = 0 {
        didSet {
            self.updateNavigationItem()
        }
    }
    
    var toolbarIsVisible = false {
        didSet {
            toggleMultipeerToolbarVisibility()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //createMultipeerToolbar()
        view.backgroundColor = .white
        
        setupNavBar()
        setupPageViewController()
    }
    
    // MARK: - Page view controller delegate/data source
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        switch index {
//        case 1: return cardsSceneController
//        default: return nil
//        }
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        switch index {
//        case 0: return personalCardsSceneController
//        default: return nil
//        }
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if completed {
////            if index == 0 {
////                index = 1
////            } else if index == 1 {
////                index = 0
////            }
//            
//            if let currentVC = pageViewController.viewcontroller {
//                if currentVC === cardsSceneController {
//                    index = 0
//                } else if currentVC === personalCardsSceneController {
//                    index = 1
//                }
//            }
//        }
//    }
    
    func confirmChangeOfMultipeer() {
        
        let title: String
        let message: String
        let completion: () -> Void
        
        switch MultipeerController.shared.connectionStatus {
        case .notConnected:
            title = "Confirm Nearby Advertise"
            message = "Would you like to advertise your device for nearby sharing?"
            completion = { MultipeerController.shared.startAdvertising() }
        case .advertising, .browsing, .connected, .connecting:
            title = "Confirm End of Nearby Session"
            message = "Would you like to end this nearby sharing session?"
            completion = { MultipeerController.shared.cancelSession() }
        }
        
        confirmMultipeerAdvertiseAlert(with: title, message: message) {
            completion()
            self.toolbarIsVisible = !self.toolbarIsVisible
        }
    }
    
    func browseSelected() {
        if !toolbarIsVisible {
            toolbarIsVisible = true
        }
    }
    
    func createMultipeerToolbar() {
        
        wirelessBarButtonItem = UIBarButtonItem(image: UIImage(named: "antenna1"), style: .plain, target: nil, action: nil)
        statusBarButtonItem = UIBarButtonItem(title: "Not connected", style: .plain, target: nil, action: nil)
        
        multipeerToolbar.setItems([wirelessBarButtonItem, statusBarButtonItem], animated: false)
        self.view.addSubview(multipeerToolbar)
        view.bringSubview(toFront: multipeerToolbar)
        view.bringSubview(toFront: navigationBar)
        
        customizeToolbarAppearance()
        setToolbarFrame(toolbar: multipeerToolbar)
    }
    
    func customizeToolbarAppearance() {
        multipeerToolbar.backgroundColor = UIColor.clear
        multipeerToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        wirelessBarButtonItem.tintColor = UIColor.white
        
        wirelessBarButtonItem.tintColor = .white
        statusBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }
    
    func setToolbarFrame(toolbar: UIToolbar) {
        multipeerToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        multipeerToolbar.widthAnchor.constraint(equalTo: self.navigationBar.widthAnchor, multiplier: 1.0).isActive = true
        multipeerToolbar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        multipeerToolbar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        multipeerToolbar.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        
        multipeerToolbar.transform = CGAffineTransform(translationX: 0.0, y: -40.0)
        multipeerToolbar.alpha = 0.0
    }
    
    func updateMultipeerToolbar(with text: String) {
        //statusBarButtonItem.title = text
        //multipeerToolbar.setItems([wirelessBarButtonItem, statusBarButtonItem], animated: false)
    }
    
    func toggleMultipeerToolbarVisibility() {
        UIView.animate(withDuration: 0.4, animations: {
            if !self.toolbarIsVisible {
                self.multipeerToolbar.transform = CGAffineTransform(translationX: 0.0, y: -self.multipeerToolbar.frame.size.height)
                if let topViewController = self.topViewController as? CardsViewController {
                    topViewController.collectionView.transform = CGAffineTransform.identity
                    self.multipeerToolbar.alpha = 0.0
                } else if let topViewController = self.topViewController as? UserProfileCollectionViewController {
                    topViewController.collectionView.transform = CGAffineTransform.identity
                    self.multipeerToolbar.alpha = 0.0
                }
            } else {
                self.multipeerToolbar.transform = CGAffineTransform.identity
                if let topViewController = self.topViewController as? CardsViewController {
                    topViewController.collectionView.transform = CGAffineTransform(translationX: 0.0, y: self.multipeerToolbar.frame.size.height)
                    self.multipeerToolbar.alpha = 1.0
                } else if let topViewController = self.topViewController as? UserProfileCollectionViewController {
                    topViewController.collectionView.transform = CGAffineTransform(translationX: 0.0, y: self.multipeerToolbar.frame.size.height)
                    self.multipeerToolbar.alpha = 1.0
                }
            }
            
        }) { (success) in }
    }
    
    func hideMultipeerToolbar() {
        if toolbarIsVisible {
            toolbarIsVisible = false
        }
    }
    
    func showMultipeerToolbar() {
        if !toolbarIsVisible {
            toolbarIsVisible = true
        }
    }
    
    func setupPageViewController() {
        guard let pageViewControllerFromIB = storyboard?.instantiateViewController(withIdentifier: "pageViewController") as? UIPageViewController else {
            fatalError("Could not instantiate the page view controller")
        }
        pageViewController = pageViewControllerFromIB
//        pageViewController.delegate = self
//        pageViewController.dataSource = self
        guard let page1 = storyboard?.instantiateViewController(withIdentifier: "cardsScene") as? CardsViewController else {
            fatalError("Could not instantiate the received cards scene")
        }
        
        guard let page2 = UIStoryboard(name: "UserProfileCollection", bundle: nil).instantiateViewController(withIdentifier: "personalCardsScene") as? UserProfileCollectionViewController else { fatalError("Could not instantiate the personal cards scene") }
        
        cardsSceneController = page1
        personalCardsSceneController = page2
        
        pageViewController.setViewControllers([page1, page2], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = view.frame
        self.pushViewController(pageViewController, animated: true)
    }
    
    func setupNavBar() {
        navigationBar.barTintColor = .clear
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    }
    
    func updateNavigationItem() {
        
    }
    
    func confirmMultipeerAdvertiseAlert(with title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            completion()
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
}
