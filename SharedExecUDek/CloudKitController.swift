//
//  CloudKitController.swift
//  ExecUDek
//
//  Created by Austin Money on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit

public class CloudKitContoller {
    
    public static let shared = CloudKitContoller()
    private let container = CKContainer(identifier: "iCloud.com.arnoldmukasa.ExecUDek")
    
    public var cards: [Card] = []
    
    public var currentUser: Person?
    
    public func create(card: Card, withCompletion completion: @escaping (CKRecord?, Error?) -> Void) {
        
        CKContainer.default().publicCloudDatabase.save(card.ckRecord) { (record, error) in
            completion(record, error)
        }
    }
    
    public func fetchCards(with predicate: NSPredicate, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: Card.recordTypeKey, predicate: predicate)
        
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            completion(records, error)
        }
    }
    
    public func fetchRecord(with recordID: CKRecordID, completion: @escaping (CKRecord?, Error?) -> Void) {
        container.publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            completion(record, error)
        }
    }
    
    public func updateRecord(recordID: CKRecordID) {
        
        fetchRecord(with: recordID) { (record, error) in
            if let error = error { NSLog("Error encountered while fetching record to update: \(error.localizedDescription)"); return }
            guard var record = record else { NSLog("Record returned for update operation is nil"); return }
            guard let person = PersonController.shared.currentPerson else { return }
            person.updateCKRecord(record: &record)
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInteractive
            
            self.container.publicCloudDatabase.add(operation)
        }
    }
    
    public func deleteRecord(recordID: CKRecordID) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID])
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        
        self.container.publicCloudDatabase.add(operation)
    }
    
    public func createUserWith(name: String, completion: @escaping (_ success: Bool) -> Void) {
        
        container.fetchUserRecordID { (appleUserRecordID, error) in
            
            if let error = error { print(error.localizedDescription); completion(false); return }
            
            guard let appleUserRecordID = appleUserRecordID else { completion(false); return }
            
            let userCKReference = CKReference(recordID: appleUserRecordID, action: .none)
            
            let user = Person(name: name, userCKReference: userCKReference)
            
            self.container.publicCloudDatabase.save(user.CKrecord, completionHandler: { (_, error) in
                
                if let error = error { print(error.localizedDescription); completion(false); return }
                
                self.currentUser = user
                
                completion(true)
            })
        }
    }
    
    public func fetchCurrentUser(completion: @escaping (Bool, Person?) -> Void) {
        
        container.fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error { print(error.localizedDescription); completion(false, nil); return }
            
            guard let appleUserRecordID = appleUserRecordID else { completion(false, nil); return }
            
            let appleUserReference = CKReference(recordID: appleUserRecordID, action: .none)
            
            let predicate = NSPredicate(format: "\(Person.appleUserReferenceKey) == %@", appleUserReference)
            
            let query = CKQuery(recordType: Person.recordType, predicate: predicate)
            
            self.container.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error { print(error.localizedDescription); completion(false, nil); return }
                
                guard let currentUserRecord = records?.first else { completion(true, nil); return }
                
                let currentPerson = Person(CKRecord: currentUserRecord)
                
                PersonController.shared.currentPerson = currentPerson
                
                completion(true, currentPerson)
            })
        }
    }
}
