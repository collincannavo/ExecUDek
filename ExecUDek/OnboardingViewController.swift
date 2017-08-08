//
//  OnboardingViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/8/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate {

    var pageArray = ["page1", "page2", "page3"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self as? UIPageViewControllerDataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
