//
//  OnboardingViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/8/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var profileArrow: UIImageView!
    @IBOutlet weak var addArrow: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1, delay: 0.25,
                       options: [.autoreverse, .repeat],
                       animations: {
                        self.profileArrow.frame.origin.y -= 20
                        self.addArrow.frame.origin.y -= 20
        })
    }

}






