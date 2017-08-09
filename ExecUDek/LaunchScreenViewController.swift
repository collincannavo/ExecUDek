//
//  LaunchScreenViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/9/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import CloudKit
import SharedExecUDek

class LaunchScreenViewController: UIPageViewController {
    
    let cloudKitManager = CloudKitContoller.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        cloudKitManager.shared.fetchCurrentUser { (_, user) in
            
            DispatchQueue.main.async {
                
                if let currentUser = user {
                    PersonController.shared.currentPerson = currentUser
                    
                    self.performSegue(withIdentifier: "toCardsSceneCollectionView", sender: self)
                } else {
                    self.performSegue(withIdentifier: "toOnboarding", sender: self)
                }
            }
            
        }
        
        
    }

}
