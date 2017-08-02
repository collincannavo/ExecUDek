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

public class CardController {
    
    public static let shared = CardController()
    
    // CRUD
    
    public func createPersonalCardWith(name: String, title: String?, cell: String?, officeNumber: String?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
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
    
    public func createCardWith(cardData: Data?, name: String, title: String?, cell: String?, officeNumber: String?, email: String?, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
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
    
    public func updateCard(_ card: Card, withCardData cardData: Data?, name: String, title: String?, cell: String?, officeNumber: String?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?) {
        
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
    
    public func fetchCards(with completion: @escaping (Bool) -> Void) {
        guard let currentPerson = PersonController.shared.currentPerson else { completion(false); return }
        currentPerson.receivedCards.forEach { receivedCardReference in
            CloudKitContoller.shared.fetchRecord(with: receivedCardReference.recordID, completion: { (record, error) in
                if let error = error { NSLog("Error encountered while fetching a referenced card: \(error.localizedDescription)"); completion(false); return }
                guard let record = record else { NSLog("Returned card record is nil"); completion(false); return }
                guard let card = Card(ckRecord: record) else { NSLog("Could not create card object from CKRecord"); completion(false); return }
                
                PersonController.shared.addCard(card, to: currentPerson)
                completion(true)
            })
        }
    }
    
    public func fetchPersonalCards(with completion: @escaping (Bool) -> Void) {
        guard let currentPersonCKRecordID = PersonController.shared.currentPerson?.cKRecordID else { completion(false); return }
        let currentPersonCKReference = CKReference(recordID: currentPersonCKRecordID, action: .none)
        let predicate = NSPredicate(format: "\(Card.parentKey) == %@", currentPersonCKReference)
        
        CloudKitContoller.shared.fetchCards(with: predicate, completion: { (records, error) in
            if let error = error {
                NSLog("Error encountered while fetching profile cards: \(error.localizedDescription)"); completion(false); return }
            
            guard let records = records else { NSLog("Returned profile cards are nil"); completion(false); return }
            guard let currentPerson = PersonController.shared.currentPerson else { completion(false); return }
            
            let cards = records.flatMap { Card(ckRecord: $0) }
            cards.forEach { PersonController.shared.addPersonalCard($0, to: currentPerson) }
            completion(true)
        })
    }
    
    public func fetchReceivedCards(with completion: @escaping (Bool) -> Void) {
        
        guard let currentPerson = PersonController.shared.currentPerson else { completion(false); return }
        
        currentPerson.receivedCards.forEach { (receivedCardReference) in
            
            CloudKitContoller.shared.fetchRecord(with: receivedCardReference.recordID, completion: { (record, error) in
                if let error = error { NSLog("Error encountered fetching a received card record: \(error.localizedDescription)"); completion(false); return }
                guard let record = record else { NSLog("Record returned for received card fetch is nil"); completion(false); return }
                guard let card = Card(ckRecord: record) else { NSLog("Could not construct Card object from received card record"); completion(false); return }
                
                if let index = currentPerson.cards.index(where: { card.ckRecordID?.recordName == $0.ckRecordID?.recordName }) {
                    currentPerson.cards.remove(at: index)
                }
            
                PersonController.shared.addCard(card, to: currentPerson)
                completion(true)
            })
        }
    }
}
