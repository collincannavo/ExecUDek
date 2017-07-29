//
//  Person.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/25/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit

class Person {
    
    static let nameKey = "name"
    static let recordType = "Person"
    static let appleUserReferenceKey = "appleUserReference"
    static let receivedCardsKey = "receivedCards"
    
    var cKRecordID: CKRecordID?
    var userCKReference: CKReference?
    let name: String
    var blockedUsers: [CKReference] = []
    var receivedCards: [CKReference] = []
    var personalCards: [Card] = []
    var cards: [Card] = []
    
    var ckReference: CKReference? {
        guard let ckRecordID = cKRecordID else { return nil }
        return CKReference(recordID: ckRecordID, action: .none)
    }
    
    var CKrecord: CKRecord {
        let recordID = self.cKRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        let record = CKRecord(recordType: Person.recordType, recordID: recordID)
        record[Person.nameKey] = name as CKRecordValue?
        record[Person.appleUserReferenceKey] = userCKReference as CKRecordValue?
        
        if !receivedCards.isEmpty {
            record[Person.receivedCardsKey] = receivedCards as CKRecordValue?
        }
        
        self.cKRecordID = recordID
        
        return record
    }
    
    init(name: String, userCKReference: CKReference) {
        self.name = name
        self.userCKReference = userCKReference
    }
    
    init?(CKRecord: CKRecord) {
        guard let name = CKRecord[Person.nameKey] as? String else { return nil }
        self.name = name
        
        self.userCKReference = CKRecord[Person.appleUserReferenceKey] as? CKReference
        
        let receivedCards = CKRecord[Person.receivedCardsKey] as? [CKReference] ?? []
        self.receivedCards = receivedCards
        
        self.cKRecordID = CKRecord.recordID
    }
    
    func updateCKRecord(record: inout CKRecord) {
        record[Person.nameKey] = name as CKRecordValue?
        record[Person.appleUserReferenceKey] = userCKReference as CKRecordValue?
        
        if !receivedCards.isEmpty {
            record[Person.receivedCardsKey] = receivedCards as CKRecordValue?
        }
    }
}

extension Person: Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name && lhs.cKRecordID == rhs.cKRecordID
    }
}
