//
//  DeadViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/9/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class DeadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentICloudLoginAlert {}
    }
    
    func presentICloudLoginAlert(with completion: @escaping () -> Void) {
        let title = "Sign in to iCloud"
        let message = "You must sign in to iCloud in the device's settings to use ExecUDek"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        present(alertController, animated: true, completion: nil)
    }

}
