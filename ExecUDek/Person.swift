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
    static let recordType = "User"
    
    var cKRecordID: CKRecordID?
    var userCKReference: CKReference?
    let name: String
    var blockedUsers: [CKReference] = []
    var receivedCards: [CKReference] = []
    var personalCards: [Card] = []
    var cards: [Card] = []
    
    var CKrecord: CKRecord {
        let recordID = self.cKRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        let record = CKRecord(recordType: Person.recordType, recordID: recordID)
        record[Person.nameKey] = name as CKRecordValue?
        
        self.cKRecordID = recordID
        
        return record
    }
    
    init(name: String, userCKReference: CKReference) {
        self.name = name
        self.userCKReference = userCKReference
    }
    
    init?(CKRecord: CKRecord) {
        guard let name = CKRecord[Person.nameKey] as? String else {return nil}
        self.name = name
        self.cKRecordID = CKRecord.recordID
        
    }
}

extension Person: Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name && lhs.cKRecordID == rhs.cKRecordID
    }
}
