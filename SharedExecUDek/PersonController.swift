//
//  PersonController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit


public class PersonController {
    
    public static let shared = PersonController()
    
    public var currentPerson: Person?
    
    public func addPersonalCard(_ card: Card, to person: Person) {
        person.personalCards.append(card)
    }
    
    public func addCard(_ card: Card, to person: Person) {
        person.cards.append(card)
    }
    
    public func addCardReference(_ reference : CKReference, to person: Person) {
        person.receivedCards.append(reference)
    }
    
    public func removeCardReference(_ reference: CKReference, from person: Person) {
        if let index = person.receivedCards.index(where: { $0 == reference }) {
            person.receivedCards.remove(at: index)
        }
    }
    
    public func deleteCard(_ card: Card, from person: Person, with completion: @escaping (Bool) -> Void) {
        if let index = person.cards.index(where: { $0 == card }) {
            person.cards.remove(at: index)
            
            if let reference = card.ckReference {
                removeCardReference(reference, from: person)
            }
            
            self.updateRecord(for: person) { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        if let index = person.personalCards.index(where: { $0 == card }) {
            person.personalCards.remove(at: index)
            CardController.shared.removeParentFrom(card: card)
            CardController.shared.updateRecord(for: card, completion: { (success) in
                if success {
                    self.updateRecord(for: person) { (success) in
                        if success {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
            })
        }
    }
    
    public func updateRecord(for person: Person, completion: @escaping (Bool) -> Void) {
        
        guard let recordID = person.cKRecordID else { completion(false); return }
        
        CloudKitContoller.shared.fetchRecord(with: recordID) { (record, error) in
            if let error = error { NSLog("Error encountered while fetching record to update: \(error.localizedDescription)"); completion(false); return }
            guard var record = record else { NSLog("Record returned for update operation is nil"); completion(false); return }
            person.updateCKRecordLocally(record: &record)
            
            CloudKitContoller.shared.updateRecord(record, with: { (records, recordIDs, error) in
                if let error = error {
                    NSLog("Error encountered fetching the Person record to modify: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard records?.first != nil else { NSLog("Did not successfully return the modified Person record"); completion(false); return }
                
                completion(true)
            })
        }
    }
}
