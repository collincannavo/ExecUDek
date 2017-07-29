//
//  Card.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/25/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class Card {
    
    static let recordTypeKey = "Card"
    static let nameKey = "name"
    static let titleKey = "title"
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
    static let imageKey = "image"
    
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
    var title: String?
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
    
    var cardData: Data?
    
    init(name: String,
         title: String? = nil,
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
        self.title = title
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
    
    var ckRecord: CKRecord {
        
        let record = CKRecord(recordType: Card.recordTypeKey)
        record.setValue(name, forKey: Card.nameKey)
        record.setValue(title, forKey: Card.titleKey)
        record.setValue(cell, forKey: Card.cellKey)
        record.setValue(officeNumber, forKey: Card.officeNumberKey)
        record.setValue(email, forKey: Card.emailKey)
        record.setValue(template.rawValue, forKey: Card.templateKey)
        record.setValue(companyName, forKey: Card.companyNameKey)
        record.setValue(note, forKey: Card.noteKey)
        record.setValue(address, forKey: Card.addressKey)
        record.setValue(avatarData, forKey: Card.avatarDataKey)
        record.setValue(logoData, forKey: Card.logoDataKey)
        record.setValue(other, forKey: Card.otherKey)
        
        record.setValue(parentCKReference, forKey: Card.parentKey)
        
        return record
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Card.nameKey] as? String,
            let templateRawValue = ckRecord[Card.templateKey] as? String,
            let template = Template(rawValue: templateRawValue) else { return nil }
        
        let title = ckRecord[Card.titleKey] as? String
        let cell = ckRecord[Card.cellKey] as? Int
        let officeNumber = ckRecord[Card.officeNumberKey] as? Int
        let email = ckRecord[Card.emailKey] as? String
        let companyName = ckRecord[Card.companyNameKey] as? String
        let note = ckRecord[Card.noteKey] as? String
        let address = ckRecord[Card.addressKey] as? String
        let avatarData = ckRecord[Card.avatarDataKey] as? Data
        let logoData = ckRecord[Card.logoDataKey] as? Data
        let other = ckRecord[Card.otherKey] as? String
        let parentCKReference = ckRecord[Card.parentKey] as? CKReference
        let imageData = ckRecord[Card.imageKey] as? Data
        
        self.init(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        if let imageDataUnwrapped = imageData {
            self.cardData = imageDataUnwrapped
        }
        
        self.ckRecordID = ckRecord.recordID
        self.parentCKReference = parentCKReference
    }
}

extension Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.title != rhs.title { return false }
        if lhs.cell != rhs.cell { return false }
        if lhs.officeNumber != rhs.officeNumber { return false }
        if lhs.email != rhs.email { return false }
        if lhs.template != rhs.template { return false }
        if lhs.companyName != rhs.companyName { return false }
        if lhs.note != rhs.note { return false }
        if lhs.address != rhs.address { return false }
        if lhs.avatarData != rhs.avatarData { return false }
        if lhs.logoData != rhs.logoData { return false }
        if lhs.other != rhs.other { return false }
        if lhs.cardData != rhs.cardData { return false }
        
        return true
    }
}
