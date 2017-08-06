//
//  CustomNavigationController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/6/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    let multipeerToolbar = UIToolbar()
    var toolbarIsVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()

        createMultipeerNavBarItem()
        createMultipeerToolbar()
    }
    
    func createMultipeerNavBarItem() {
        let wirelessBarButtonItem = UIBarButtonItem(image: UIImage(named: "wirelessIconWhite"), style: .plain, target: self, action: #selector(multipeerNavBarItemTapped))
        
        if let rightNavBarItems = navigationItem.rightBarButtonItems {
            navigationItem.setRightBarButtonItems(rightNavBarItems + [wirelessBarButtonItem], animated: false)
        } else if let rightNavBarItem = navigationItem.rightBarButtonItem {
            navigationItem.setRightBarButtonItems([rightNavBarItem, wirelessBarButtonItem], animated: false)
        } else {
            navigationItem.setRightBarButton(wirelessBarButtonItem, animated: false)
        }
    }
    
    func multipeerNavBarItemTapped() {
        toggleMultipeerToolbarVisibility()
    }
    
    func createMultipeerToolbar() {
        
        let wirelessBarButtonItem = UIBarButtonItem(image: UIImage(named: "wirelessIconWhite"), style: .plain, target: nil, action: nil)
        
        multipeerToolbar.setItems([wirelessBarButtonItem], animated: false)
        self.view.addSubview(multipeerToolbar)
        view.bringSubview(toFront: multipeerToolbar)
        setToolbarFrame(toolbar: multipeerToolbar)
    }
    
    func setToolbarFrame(toolbar: UIToolbar) {
        multipeerToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        multipeerToolbar.widthAnchor.constraint(equalTo: self.navigationBar.widthAnchor, multiplier: 1.0).isActive = true
        multipeerToolbar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        multipeerToolbar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        multipeerToolbar.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        
        multipeerToolbar.transform = CGAffineTransform(translationX: 0.0, y: -multipeerToolbar.frame.size.height)
    }
    
    func updateMultipeerToolbar(with text: String) {
        
    }
    
    func toggleMultipeerToolbarVisibility() {
        UIView.animate(withDuration: 0.4, animations: { 
            if self.toolbarIsVisible {
                self.multipeerToolbar.transform = CGAffineTransform(translationX: 0.0, y: -self.multipeerToolbar.frame.size.height)
            } else {
                self.multipeerToolbar.transform = CGAffineTransform.identity
            }
            
        }) { (success) in }
    }
}
