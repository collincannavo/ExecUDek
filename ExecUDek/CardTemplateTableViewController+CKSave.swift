//
//  CardTemplateTableViewController+CKSave.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/27/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import UIKit

extension CardTemplateTableViewController {
    
   
    func saveCardToCloudKit() {
        
        guard let name = nameTextField.text else { return }
        
        let positon = titleTextField.text
        let cell = Int(cellTextField.text ?? "")
        let email = emailTextField.text
        
        let officeNumber = Int(officeNumberTextField.text ?? "")
        let template = Template.one
        let note = noteTextField.text
        let address = addressTextField.text
        //let logoData = UIImagePNGRepresentation(logoImageView.image)
        //let other = otherTextField.text
        
        //let cardData = UIImagePNGRepresentation(cardPhotoImageView.image)
        
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(cardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, companyName: nil, note: nil, address: address, avatarData: nil, logoData: nil, other: nil)
        case (false, true):
            CardController.shared.createPersonalCardWith(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: note, address: address, avatarData: nil, logoData: nil, other: nil)
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(card, withCardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: note, address: address, avatarData: nil, logoData: nil, other: nil)
        }
    }
    
    func updateViews() {
        nameTextField.text = card?.name
        titleTextField.text = card?.title
        emailTextField.text = card?.email
        officeNumberTextField.text = "\(card?.officeNumber)"
        noteTextField.text = card?.note
        addressTextField.text = card?.address
        
        if let logoData = card?.logoData {
            //logoImageView.image = UIImage(data: logoData)
        }
        
        if let cardData = card?.cardData {
            //cardPhotoImageView.image = UIImage(data: cardData)
        }
    }
}
