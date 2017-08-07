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
    
    var toolbarIsVisible = false {
        didSet {
            toggleMultipeerToolbarVisibility()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMultipeerToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(multipeerNavBarItemTapped), name: Constants.multipeerNavBarItemTappedNotification, object: nil)
        
        view.backgroundColor = .white
    }
    
    func multipeerNavBarItemTapped() {
        
        let title: String
        let message: String
        let completion: () -> Void
        
        if !toolbarIsVisible {
            title = "Confirm Multipeer Advertise"
            message = "Would you like to advertise your device for Multipeer sharing?"
            completion = { NotificationCenter.default.post(name: Constants.advertiseMultipeerNotification, object: self) }
            
        } else {
            title = "Confirm End of Multipeer Advertise"
            message = "Would you like to stop advertising your device for Multipeer sharing?"
            completion = { NotificationCenter.default.post(name: Constants.endAdvertiseMultipeerNotification, object: self) }
        }
        confirmMultipeerAdvertiseAlert(with: title, message: message) {
            completion()
            self.toolbarIsVisible = !self.toolbarIsVisible
        }
    }
    
    func createMultipeerToolbar() {
        
        wirelessBarButtonItem = UIBarButtonItem(image: UIImage(named: "wirelessIconWhite"), style: .plain, target: nil, action: nil)
        statusBarButtonItem = UIBarButtonItem(title: "Not connected", style: .plain, target: nil, action: nil)
        
        multipeerToolbar.setItems([wirelessBarButtonItem, statusBarButtonItem], animated: false)
        self.view.addSubview(multipeerToolbar)
        view.bringSubview(toFront: multipeerToolbar)
        view.bringSubview(toFront: navigationBar)
        
        setToolbarFrame(toolbar: multipeerToolbar)
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
        statusBarButtonItem.title = text
        multipeerToolbar.setItems([wirelessBarButtonItem, statusBarButtonItem], animated: false)
    }
    
    func toggleMultipeerToolbarVisibility() {
        UIView.animate(withDuration: 0.4, animations: {
            if !self.toolbarIsVisible {
                self.multipeerToolbar.transform = CGAffineTransform(translationX: 0.0, y: -self.multipeerToolbar.frame.size.height)
                self.topViewController?.view.transform = CGAffineTransform.identity
                self.multipeerToolbar.alpha = 0.0
            } else {
                self.multipeerToolbar.transform = CGAffineTransform.identity
                self.topViewController?.view.transform = CGAffineTransform(translationX: 0.0, y: self.multipeerToolbar.frame.size.height)
                self.multipeerToolbar.alpha = 1.0
            }
            
        }) { (success) in }
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
