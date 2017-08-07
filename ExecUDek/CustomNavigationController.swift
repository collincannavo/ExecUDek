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
    
    var connectionStatus = ConnectionStatus.notConnected
    
    var toolbarIsVisible = false {
        didSet {
            toggleMultipeerToolbarVisibility()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMultipeerToolbar()
        addNotificationObserver()
        view.backgroundColor = .white
    }
    
    func confirmChangeOfMultipeer() {
        
        let title: String
        let message: String
        let completion: () -> Void
        
        switch connectionStatus {
        case .notConnected:
            title = "Confirm Multipeer Advertise"
            message = "Would you like to advertise your device for Multipeer sharing?"
            completion = { NotificationCenter.default.post(name: Constants.advertiseMultipeerNotification, object: self) }
        case .advertising, .browsing, .connected, .connecting:
            title = "Confirm End of Multipeer Session"
            message = "Would you like to end this Multipeer session?"
            completion = { NotificationCenter.default.post(name: Constants.endMultipeerNotification, object: self) }
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
    
    func hideMultipeerToolbar() {
        if toolbarIsVisible {
            toolbarIsVisible = false
        }
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
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(confirmChangeOfMultipeer), name: Constants.multipeerNavBarItemTappedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(browseSelected), name: Constants.browseMultipeerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMultipeerToolbar), name: Constants.hideMultipeerToolbarNotification, object: nil)
    }
}
