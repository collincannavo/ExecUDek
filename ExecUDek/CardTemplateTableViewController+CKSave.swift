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
    
    var cardSenderIsMainScene: Bool = true
    var card: Card?
    
    func saveCardToCloudKit() {
        
        let name = commonCard.nameTextField.text
        let positon = commonCard.positionTextField.text
        let cell = commonCard.cellTextField.text
        let email = commonCard.emailTextField.text
        
        let officeNumber = officeNumberTextField.text
        let template = Template.one
        let companyName = companyNameTextField.text
        let note = noteTextField.text
        let address = addressTextField.text
        let logoData = UIImagePNGRepresentation(logoImageView.image)
        let other = otherTextField.text
        
        let cardData = UIImagePNGRepresentation(cardPhotoImageView.image)
        
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        case (false, true):
            CardController.shared.createPersonalCardWith(cardData: cardData, name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(_ card: Card, withCardData: cardData, name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        }
    }
    
    func updateViews() {
        nameTextField.text = card?.name
        positionTextField.text = card?.position
        emailTextField.text = card?.email
        officeNumberTextField.text = card?.officeNumber
        companyNameTextField.text = card?.companyName
        noteTextField.text = card?.note
        addressTextField.text = card?.address
        
        if let logoData = card?.logoData {
            logoImageView.image = UIImage(data: logoData)
        }
        
        otherTextField.text = card?.other
        
        if let cardData = card?.cardData {
            cardPhotoImageView.image = UIImage(data: cardData)
        }
    }
}
