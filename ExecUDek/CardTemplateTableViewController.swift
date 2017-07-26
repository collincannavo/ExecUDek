//
//  CardTemplateTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class CardTemplateTableViewController: UITableViewController {
    
    // TableView textFields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var jobTextfield: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    // UIView labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty, let job = jobTextfield.text, let address = addressTextField.text, let city = cityTextField.text, let phone = phoneTextField.text, let fax = faxTextField.text, let email = emailTextField.text, let website = websiteTextField.text else {return}
        
        nameLabel.text = name
        jobLabel.text = job
        addressLabel.text = address
        cityLabel.text = city
        phoneLabel.text = phone
        faxLabel.text = fax
        emailLabel.text = email
        websiteLabel.text = website
    }
    
    
    //View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    //Private function
    fileprivate func updateView(){
        // Update view
    }
}
