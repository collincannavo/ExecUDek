//
//  UserProfileTableViewCell.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/27/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek

class UserProfileTableViewCell: UITableViewCell {
    
    var card: Card? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var logoPhotoImageView: UIImageView!
    
    func updateView(){
        guard let card = card else {return}
        nameLabel.text = card.name
        jobLabel.text = "Job title"
        addressLabel.text = card.address
        cityLabel.text = "City"
        phoneLabel.text = "\(String(describing: card.officeNumber))"
        faxLabel.text = "Fax"
        emailLabel.text = card.email
        websiteLabel.text = "Website"
        if let logoData = card.logoData { logoPhotoImageView.image = UIImage(data: logoData) }        
    }
}
