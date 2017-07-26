//
//  Card.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/25/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit

class Card {
    
    static let recordTypeKey = "Card"
    
    static let nameKey = "name"
    static let cellKey = "cell"
    static let officeNumberKey = "officeNumber"
    static let emailKey = "email"
    static let templateKey = "template"
    static let companyNameKey = "companyName"
    static let noteKey = "note"
    static let addressKey = "address"
    static let avatarDataKey = "avatarData"
    static let logoDataKey = "logoData"
    static let otherKey = "other"
    static let parentKey = "parent"
    
    // Cloud kit syncable
    var ckRecordID: CKRecordID?
    
    var ckReference: CKReference? {
        guard let ckRecordID = ckRecordID else { return nil }
        return CKReference(recordID: ckRecordID, action: .none)
    }
    
    var parentCKRecordID: CKRecordID? {
        return parentCKReference?.recordID
    }
    
    var parentCKReference: CKReference?
    
    var name: String
    var cell: Int?
    var officeNumber: Int?
    var email: String?
    var template: Template
    var companyName: String?
    var note: String?
    var address: String?
    var avatarData: Data?
    var logoData: Data?
    var other: String?
    
    init(name: String,
         cell: Int? = nil,
         officeNumber: Int? = nil,
         email: String? = nil,
         template: Template,
         companyName: String? = nil,
         note: String? = nil,
         address: String? = nil,
         avatarData: Data? = nil,
         logoData: Data? = nil,
         other: String? = nil) {
        
        self.name = name
        self.cell = cell
        self.officeNumber = officeNumber
        self.email = email
        self.template = template
        self.companyName = companyName
        self.note = note
        self.address = address
        self.avatarData = avatarData
        self.logoData = logoData
        self.other = other
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Card.nameKey] as? String,
            let templateRawValue = ckRecord[Card.templateKey] as? String,
            let template = Template(rawValue: templateRawValue) else { return nil }
        
        let cell = ckRecord[Card.cellKey] as? String
        let officeNumber = ckRecord[Card.officeNumberKey] as? String
        let email = ckRecord[Card.emailKey] as? String
        let companyName = ckRecord[Card.companyNameKey] as? String
        let note = ckRecord[Card.noteKey] as? String
        let address = ckRecord[Card.addressKey] as? String
        let avatarData = ckRecord[Card.avatarDataKey] as? Data
        let logoData = ckRecord[Card.logoDataKey] as? Data
        let other = ckRecord[Card.otherKey] as? String
        let parentCKReference = ckRecord[Card.parentKey] as? CKReference
        
        self.init(name: name, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        self.ckRecordID = ckRecord.recordID
        self.parentCKReference = parentCKReference
    }
}




































