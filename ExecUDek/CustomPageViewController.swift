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

        let addCardBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.rightBarButtonItem = addCardBarButtonItem
    }
}
