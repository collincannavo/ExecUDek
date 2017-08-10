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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        CloudKitContoller.shared.verifyCloudKitLogin { (success) in
            if success {
                self.fetchData()
            } else {
                self.performSegue(withIdentifier: "showDeadScene", sender: self)
            }
        }
    }
    
    func fetchData() {
        CloudKitContoller.shared.fetchCurrentUser { (success, person) in
            if success {
                if person != nil {
                    CardController.shared.fetchPersonalCards(with: { (success) in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Constants.personalCardsFetchedNotification, object: self)
                        }
                    })
                    CardController.shared.fetchReceivedCards(with: { (success) in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Constants.cardsFetchedNotification, object: self)
                        }
                    })
                    
                    self.performSegue(withIdentifier: "toCardsSceneCollectionView", sender: self)
                    
                } else {
                    CloudKitContoller.shared.createUserWith(name: "Test", completion: { (_) in
                        self.performSegue(withIdentifier: "toOnboarding", sender: self)
                    })
                }
            }
        }
    }
}
