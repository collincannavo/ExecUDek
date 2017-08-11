//
//  CustomPageViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/11/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class CustomPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    func setupBackgroundImage() {
        let image = UIImage(named: "skylineDarkened")
        let imageView = UIImageView (image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let addCardBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let multipeerBarButtonItem = UIBarButtonItem(image: UIImage(named: "antennaFinal"), style: .plain, target: self, action: nil)
        let profileBarButtonItem = UIBarButtonItem(image: UIImage(named: "profileIcon4"), style: .plain, target: self, action: nil)
        let homeBarButtonItem = UIBarButtonItem(image: UIImage(named: "HomeIcon"), style: .plain, target: self, action: nil)
        
        addCardBarButtonItem.tintColor = .white
        multipeerBarButtonItem.tintColor = .white
        profileBarButtonItem.tintColor = .white
        homeBarButtonItem.tintColor = .white
        
        navigationItem.rightBarButtonItems = [addCardBarButtonItem, multipeerBarButtonItem]
        navigationItem.leftBarButtonItem = profileBarButtonItem
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.automaticallyAdjustsScrollViewInsets = false
    }
}
