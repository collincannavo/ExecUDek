//
//  OnboardingPage4ViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/10/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class OnboardingPage4ViewController: UIViewController {
    
    @IBOutlet weak var createCardNowButton: UIButton!
    @IBOutlet weak var createCardLaterButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupCardNow" {
            UIView.animate(withDuration: 2.0, animations: {
                self.createCardNowButton.isHidden = true
                self.createCardLaterButton.isHidden = true
                self.walletButton.isHidden = false
            })
        }
    }
}
