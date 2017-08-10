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
    
    public func createPersonalCardWith(name: String, title: String?, cell: String?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?, completion: @escaping (Bool) -> Void) {
        
        guard let person = PersonController.shared.currentPerson else { completion(false); return }
        
        let card = Card(name: name, title: title, cell: cell, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        PersonController.shared.addPersonalCard(card, to: person)
        card.parentCKReference = PersonController.shared.currentPerson?.ckReference
        
        CloudKitContoller.shared.save(record: card.ckRecord) { (record, error) in
            if let error = error {
                NSLog("Error encountered while saving personal card to CK: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func createCardWith(cardData: Data?, name: String, title: String?, cell: String?, email: String?, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?, completion: @escaping (Bool) -> Void) {
        
        let template = Template.one
        
        guard let person = PersonController.shared.currentPerson else { completion(false); return }
        
        let card = Card(name: name, title: title, cell: cell, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        card.cardData = cardData
        
        CloudKitContoller.shared.save(record: card.ckRecord) { (record, error) in
            if let error = error { NSLog("Error encountered while saving card to CK: \(error.localizedDescription)"); completion(false); return }
            
            guard let record = record else { completion(false); return }
            
            let reference = CKReference(recordID: record.recordID, action: .none)
            
            PersonController.shared.addCard(card, to: person)
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
    
    public func updateCard(_ card: Card, withCardData cardData: Data?, name: String, title: String?, cell: String?, email: String?, template: Template, companyName: String?, note: String?, address: String?, avatarData: Data?, logoData: Data?, other: String?, completion: @escaping (Bool) -> Void) {
        
        card.cardData = cardData
        card.name = name
        card.title = title
        card.cell = cell
        card.email = email
        card.template = template
        card.companyName = companyName
        card.note = note
        card.address = address
        card.avatarData = avatarData
        card.logoData = logoData
        card.other = other
        
        updateRecord(for: card) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func removeParentFrom(card: Card) {
        card.parentCKReference = nil
    }
    
    public func fetchPersonalCards(with completion: @escaping (Bool) -> Void) {
        guard let currentPersonCKRecordID = PersonController.shared.currentPerson?.cKRecordID else { completion(false); return }
        let currentPersonCKReference = CKReference(recordID: currentPersonCKRecordID, action: .none)
        let predicate = NSPredicate(format: "\(Card.parentKey) == %@", currentPersonCKReference)
        
        CloudKitContoller.shared.performQuery(with: predicate, completion: { (records, error) in
            
            PersonController.shared.currentPerson?.initialPersonalCardsFetchComplete = true
            
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
        
        PersonController.shared.removalAllCards(from: currentPerson)
        
        let receivedCardsRecordIDs = currentPerson.receivedCards.map({ $0.recordID })
        
        CloudKitContoller.shared.fetchRecords(for: receivedCardsRecordIDs) { (recordsDictionary, error) in
            
            PersonController.shared.currentPerson?.initialCardsFetchComplete = true
            
            var success = false
            defer { completion(success) }
            
            if let error = error { NSLog("Error encountered fetching received cards: \(error.localizedDescription)") }
            guard let cardRecordsDictionary = recordsDictionary else { NSLog("Records returned for received card fetch is nil"); return }
            let newCards = cardRecordsDictionary.flatMap({ Card(ckRecord: $0.value) })
            
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
                
                guard (records?.first != nil) else { NSLog("Did not successfully return the modified Card record"); completion(false); return }
                
                completion(true)
            })
        }
    }
    
    public func copyCard(_ card: Card, with completion: @escaping (Bool) -> Void) {
        createCardWith(cardData: card.cardData, name: card.name, title: card.title, cell: card.cell, email: card.email, companyName: card.companyName, note: card.note, address: card.address, avatarData: card.avatarData, logoData: card.logoData, other: card.other) { (success) in
        
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func createCKAsset(for data: Data?) -> CKAsset? {
        guard let data = data,
            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        let directoryAsNSString = directory as NSString
        let path = directoryAsNSString.appendingPathComponent("asset.txt")
        
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        let fileURL = URL(fileURLWithPath: path)
        
        return CKAsset(fileURL: fileURL)
    }
}
