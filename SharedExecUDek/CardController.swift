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
        
        CloudKitContoller.shared.save(record: card.ckRecord) { (record, error) in
            if let error = error {
                NSLog("Error encountered while saving personal card to CK: \(error.localizedDescription)")
                return
            }
        }
    }
    
    public func createCardWith(cardData: Data?, name: String, title: String?, cell: String?, officeNumber: String?, email: String?, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?, completion: @escaping (Bool) -> Void) {
        
        let template = Template.one
        
        guard let person = PersonController.shared.currentPerson else { completion(false); return }
        
        let card = Card(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        PersonController.shared.addCard(card, to: person)
        card.cardData = cardData
        
        CloudKitContoller.shared.save(record: card.ckRecord) { (record, error) in
            if let error = error { NSLog("Error encountered while saving card to CK: \(error.localizedDescription)"); completion(false); return }
            
            guard let record = record else { completion(false); return }
            
            let reference = CKReference(recordID: record.recordID, action: .none)
            
            PersonController.shared.addCardReference(reference, to: person)
            
            PersonController.shared.updateRecord(for: person, completion: { (success) in
                if !success {
                    completion(false)
                } else {
                    completion(true)
                }
            })
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
    }
    
    public func removeParentFrom(card: Card) {
        card.parentCKReference = nil
    }
    
    public func fetchPersonalCards(with completion: @escaping (Bool) -> Void) {
        guard let currentPersonCKRecordID = PersonController.shared.currentPerson?.cKRecordID else { completion(false); return }
        let currentPersonCKReference = CKReference(recordID: currentPersonCKRecordID, action: .none)
        let predicate = NSPredicate(format: "\(Card.parentKey) == %@", currentPersonCKReference)
        
        CloudKitContoller.shared.performQuery(with: predicate, completion: { (records, error) in
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
        
        let receivedCardsRecordIDs = currentPerson.receivedCards.map({ $0.recordID })
        
        CloudKitContoller.shared.fetchRecords(for: receivedCardsRecordIDs) { (recordsDictionary, error) in
            
            var success = false
            defer { completion(success) }
            
            if let error = error { NSLog("Error encountered fetching received cards: \(error.localizedDescription)") }
            guard let cardRecordsDictionary = recordsDictionary else { NSLog("Records returned for received card fetch is nil"); return }
            let currentCardRecordIDs = currentPerson.cards.flatMap { $0.ckRecordID }
            let newCardsDictionary = cardRecordsDictionary.filter { !currentCardRecordIDs.contains($0.key) }
            let newCardRecords = newCardsDictionary.map({ $0.value })
            let newCards = newCardRecords.flatMap({ Card(ckRecord: $0) })
            
            newCards.forEach({ PersonController.shared.addCard($0, to: currentPerson) })
            success = true
        }
    }
    
    public func updateRecord(for card: Card, completion: @escaping (Bool) -> Void) {
        
        guard let recordID = card.ckRecordID else { completion(false); return }
        
        CloudKitContoller.shared.fetchRecord(with: recordID) { (record, error) in
            if let error = error { NSLog("Error encountered while fetching record to update: \(error.localizedDescription)"); completion(false); return }
            guard var record = record else { NSLog("Record returned for update operation is nil"); completion(false); return }
            card.updateCKRecordLocally(record: &record)
            
            CloudKitContoller.shared.updateRecord(record, with: { (records, recordIDs, error) in
                if let error = error {
                    NSLog("Error encountered fetching the Person record to modify: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let record = records?.first else { NSLog("Did not successfully return the modified Card record"); completion(false); return }
                
                completion(true)
            })
        }
    }
}
