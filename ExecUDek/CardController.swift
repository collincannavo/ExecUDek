//
//  CardController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import UIKit

class CardController {
    
    static let shared = CardController()
    
    // CRUD
    
    func createPersonalCardWith(name: String, cell: Int?, officeNumber: Int?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        guard let person = PersonController.shared.currentPerson else { return }
        
        let card = Card(name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        PersonController.shared.addPersonalCard(card, to: person)
    }
    
    func createCardWith(image: UIImage, name: String, cell: Int?, officeNumber: Int?, email: String?, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        let template = Template.one
        
        let card = Card(name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        card.cardImage = image
    }
    
    func updateCard(_ card: Card, withImage image: UIImage, name: String, cell: Int?, officeNumber: Int?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        card.cardImage = image
        card.name = name
        card.cell = cell
        card.officeNumber = officeNumber
        card.email = email
        card.template = template
        card.companyName = companyName
        card.note = note
        card.address = address
        card.avatarData = avatarData
        card.logoData = logoData
        card.other = other
    }
}