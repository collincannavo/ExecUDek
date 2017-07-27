//
//  CloudKitController.swift
//  ExecUDek
//
//  Created by Austin Money on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitContoller {
    
    static let shared = CloudKitContoller()
    
    var cards: [Card] = []
    
    var currentUser: Person?
    
    func create(card: Card) {
        
        CKContainer.default().publicCloudDatabase.save(card.ckRecord) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.cards.append(card)
            }
        }
    }
    
    func fetchCards() {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Card.recordTypeKey, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let records = records else { return }
            
            self.cards = records.flatMap { Card(ckRecord: $0) }
        }
    }
    
    func updateRecord(record: CKRecord) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func deleteRecord(record: CKRecord) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func createUserWith(name: String, completion: @escaping (_ success: Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            guard let appleUserRecordID = appleUserRecordID else { completion(false); return }
            
            let userCKReference = CKReference(recordID: appleUserRecordID, action: .none)
            
            let user = Person(name: name, userCKReference: userCKReference)
            
            CKContainer.default().publicCloudDatabase.save(user.CKrecord, completionHandler: { (_, error) in
                
                if let error = error { print(error.localizedDescription); completion(false); return }
                
                self.currentUser = user
                
                completion(true)
                
            })
            
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error { print(error.localizedDescription) }
            
            guard let appleUserRecordID = appleUserRecordID else { completion(false); return }
            
            let appleUserReference = CKReference(recordID: appleUserRecordID, action: .none)
            
            let predicate = NSPredicate(format: "appleUserReference == %@", appleUserReference)
            
            let query = CKQuery(recordType: Person.recordType, predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error { print(error.localizedDescription) }
                
                guard let currentUserRecord = records?.first else { completion(false); return }
                
                let currentUser = Person(CKRecord: currentUserRecord)
                
                self.currentUser = currentUser
                
                completion(true)
            })
        }
    }
    
}

