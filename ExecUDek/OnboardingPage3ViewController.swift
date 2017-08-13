//
//  OnboardingPage3ViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/9/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class OnboardingPage3ViewController: UIViewController {

    @IBOutlet weak var arrow: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1, delay: 0.25,
                       options: [.autoreverse, .repeat],
                       animations: {
                        self.arrow.frame.origin.y -= 20
        })
    }
}
