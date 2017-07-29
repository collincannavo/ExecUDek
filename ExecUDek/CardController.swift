//
//  CardController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CardController {
    
    static let shared = CardController()
    
    // CRUD
    
    func createPersonalCardWith(name: String, title: String?, cell: Int?, officeNumber: Int?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        guard let person = PersonController.shared.currentPerson else { return }
        
        let card = Card(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        PersonController.shared.addPersonalCard(card, to: person)
        card.parentCKReference = PersonController.shared.currentPerson?.ckReference
        
        CloudKitContoller.shared.create(card: card) { (record, error) in
            if let error = error {
                NSLog("Error encountered while saving personal card to CK: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func createCardWith(cardData: Data?, name: String, title: String?, cell: Int?, officeNumber: Int?, email: String?, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        let template = Template.one
        
        guard let person = PersonController.shared.currentPerson else { return }
        
        let card = Card(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        PersonController.shared.addCard(card, to: person)
        card.cardData = cardData
        
        CloudKitContoller.shared.create(card: card) { (record, error) in
            if let error = error {
                NSLog("Error encountered while saving card to CK: \(error.localizedDescription)")
                return
            }
            
            guard let personCKRecordID = person.cKRecordID,
                let record = record else { return }
            
            let reference = CKReference(recordID: record.recordID, action: .none)
            
            PersonController.shared.addCardReference(reference, to: person)
            CloudKitContoller.shared.updateRecord(recordID: personCKRecordID)
        }
    }
    
    func updateCard(_ card: Card, withCardData cardData: Data?, name: String, title: String?, cell: Int?, officeNumber: Int?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
        card.cardData = cardData
        card.name = name
        card.title = title
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
        
        //CloudKitContoller.shared.updateRecord(record: <#T##CKRecord#>)
    }
    
    func fetchCards() {
        guard let currentPerson = PersonController.shared.currentPerson else { return }
        currentPerson.receivedCards.forEach { receivedCardReference in
            CloudKitContoller.shared.fetchRecord(with: receivedCardReference.recordID, completion: { (record, error) in
                if let error = error { NSLog("Error encountered while fetching a referenced card: \(error.localizedDescription)"); return }
                guard let record = record else { NSLog("Returned card record is nil"); return }
                guard let card = Card(ckRecord: record) else { NSLog("Could not create card object from CKRecord"); return }
                
                PersonController.shared.addCard(card, to: currentPerson)
            })
        }
    }
    
    func fetchPersonalCards() {
        guard let currentPersonCKRecordID = PersonController.shared.currentPerson?.cKRecordID else { return }
        let currentPersonCKReference = CKReference(recordID: currentPersonCKRecordID, action: .none)
        let predicate = NSPredicate(format: "\(Card.parentKey) == %@", currentPersonCKReference)
        
        CloudKitContoller.shared.fetchCards(with: predicate, completion: { (records, error) in
            if let error = error {
                NSLog("Error encountered while fetching profile cards: \(error.localizedDescription)"); return }
            
            guard let records = records else { NSLog("Returned profile cards are nil"); return }
            guard let currentPerson = PersonController.shared.currentPerson else { return }
            
            let cards = records.flatMap { Card(ckRecord: $0) }
            cards.forEach { PersonController.shared.addPersonalCard($0, to: currentPerson) }
        })
    }
    
    func fetchReceivedCards() {
        
        guard let currentPerson = PersonController.shared.currentPerson else { return }
        
        currentPerson.receivedCards.forEach { (receivedCardReference) in
            
            CloudKitContoller.shared.fetchRecord(with: receivedCardReference.recordID, completion: { (record, error) in
                if let error = error { NSLog("Error encountered fetching a received card record: \(error.localizedDescription)"); return }
                guard let record = record else { NSLog("Record returned for received card fetch is nil"); return }
                guard let card = Card(ckRecord: record) else { NSLog("Could not construct Card object from received card record"); return }
                
                PersonController.shared.addCard(card, to: currentPerson)
            })
        }
    }
}
