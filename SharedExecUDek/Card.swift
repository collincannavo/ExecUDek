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

public class Card: NSObject, NSCoding {
    
    public static let recordTypeKey = "Card"
    public static let nameKey = "name"
    public static let titleKey = "title"
    public static let cellKey = "cell"
    public static let officeNumberKey = "officeNumber"
    public static let emailKey = "email"
    public static let templateKey = "template"
    public static let companyNameKey = "companyName"
    public static let noteKey = "note"
    public static let addressKey = "address"
    public static let avatarDataKey = "avatarData"
    public static let logoDataKey = "logoData"
    public static let otherKey = "other"
    public static let parentKey = "parent"
    public static let imageKey = "image"
    public static let ckRecordIDKey = "ckRecordID"
    
    // Cloud kit syncable
    public var ckRecordID: CKRecordID?
    
    public var ckReference: CKReference? {
        
        guard let ckRecordID = ckRecordID else { return nil }
        
        return CKReference(recordID: ckRecordID, action: .none)
    }
    
    public var parentCKRecordID: CKRecordID? {
        return parentCKReference?.recordID
    }
    
    public var parentCKReference: CKReference?
    
    public var name: String
    public var title: String?
    public var cell: String?
    public var officeNumber: String?
    public var email: String?
    public var template: Template
    public var companyName: String?
    public var note: String?
    public var address: String?
    public var avatarData: Data?
    public var logoData: Data?
    public var other: String?
    
    public var cardData: Data?
    
    public init(name: String,
         title: String? = nil,
         cell: String? = nil,
         officeNumber: String? = nil,
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
    
    public var ckRecord: CKRecord {
        
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
    
    public convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Card.nameKey] as? String,
            let templateRawValue = ckRecord[Card.templateKey] as? String,
            let template = Template(rawValue: templateRawValue) else { return nil }
        
        let title = ckRecord[Card.titleKey] as? String
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
        let imageData = ckRecord[Card.imageKey] as? Data
        
        self.init(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        if let imageDataUnwrapped = imageData {
            self.cardData = imageDataUnwrapped
        }
        
        self.ckRecordID = ckRecord.recordID
        self.parentCKReference = parentCKReference
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.value(forKey: Card.nameKey) as? String else { return nil }
        let title = aDecoder.value(forKey: Card.titleKey) as? String
        let cellphone = aDecoder.value(forKey: Card.cellKey) as? String
        let officeNumber = aDecoder.value(forKey: Card.officeNumberKey) as? String
        let email = aDecoder.value(forKey: Card.emailKey) as? String
        let companyName = aDecoder.value(forKey: Card.companyNameKey) as? String
        let note = aDecoder.value(forKey: Card.noteKey) as? String
        let address = aDecoder.value(forKey: Card.addressKey) as? String
        let avatarData = aDecoder.value(forKey: Card.avatarDataKey) as? Data
        let logoData = aDecoder.value(forKey: Card.logoDataKey) as? Data
        let other = aDecoder.value(forKey: Card.otherKey) as? String
        let cardData = aDecoder.value(forKey: Card.imageKey) as? Data
        let ckRecordID = aDecoder.value(forKey: Card.ckRecordIDKey) as? CKRecordID
        
        self.init(name: name, title: title, cell: cellphone, officeNumber: officeNumber, email: email, template: Template.one, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        self.ckRecordID = ckRecordID
        self.cardData = cardData
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.setValue(name, forKey: Card.nameKey)
        aCoder.setValue(avatarData, forKey: Card.avatarDataKey)
        aCoder.setValue(cell, forKey: Card.cellKey)
        aCoder.setValue(companyName, forKey: Card.companyNameKey)
        aCoder.setValue(email, forKey: Card.emailKey)
        aCoder.setValue(note, forKey: Card.noteKey)
        aCoder.setValue(address, forKey: Card.addressKey)
        aCoder.setValue(logoData, forKey: Card.logoDataKey)
        aCoder.setValue(other, forKey: Card.otherKey)
        aCoder.setValue(officeNumber, forKey: Card.officeNumberKey)
        aCoder.setValue(title, forKey: Card.titleKey)
        aCoder.setValue(ckRecordID, forKey: Card.ckRecordIDKey)
        aCoder.setValue(cardData, forKey: Card.imageKey)
    }
}

func ==(lhs: Card, rhs: Card) -> Bool {
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
