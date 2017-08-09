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

public class Card: NSObject {
    
    public static let recordTypeKey = "Card"
    public static let nameKey = "name"
    public static let titleKey = "title"
    public static let cellKey = "cell"
    public static let emailKey = "email"
    public static let templateKey = "template"
    public static let companyNameKey = "companyName"
    public static let noteKey = "note"
    public static let addressKey = "address"
    public static let avatarDataKey = "avatarData"
    public static let logoDataKey = "logoAsset"
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
        record.setValue(email, forKey: Card.emailKey)
        record.setValue(template.rawValue, forKey: Card.templateKey)
        record.setValue(companyName, forKey: Card.companyNameKey)
        record.setValue(note, forKey: Card.noteKey)
        record.setValue(address, forKey: Card.addressKey)
        record.setValue(avatarData, forKey: Card.avatarDataKey)
        let logoDataAsset = CardController.shared.createCKAsset(for: logoData)
        record.setValue(logoDataAsset, forKey: Card.logoDataKey)
        record.setValue(other, forKey: Card.otherKey)
        
        record.setValue(parentCKReference, forKey: Card.parentKey)
        
        self.ckRecordID = record.recordID
        
        return record
    }
    
    public convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Card.nameKey] as? String,
            let templateRawValue = ckRecord[Card.templateKey] as? String,
            let template = Template(rawValue: templateRawValue) else { return nil }
        
        let title = ckRecord[Card.titleKey] as? String
        let cell = ckRecord[Card.cellKey] as? String
        let email = ckRecord[Card.emailKey] as? String
        let companyName = ckRecord[Card.companyNameKey] as? String
        let note = ckRecord[Card.noteKey] as? String
        let address = ckRecord[Card.addressKey] as? String
        let avatarData = ckRecord[Card.avatarDataKey] as? Data
        let logoAsset = ckRecord[Card.logoDataKey] as? CKAsset
        var logoData: Data?
        if let logoDataURL = logoAsset?.fileURL {
            logoData = try? Data(contentsOf: logoDataURL, options: .mappedIfSafe)
        }
        
        let other = ckRecord[Card.otherKey] as? String
        let parentCKReference = ckRecord[Card.parentKey] as? CKReference
        let imageData = ckRecord[Card.imageKey] as? Data
        
        self.init(name: name, title: title, cell: cell, email: email, template: template, companyName: companyName, note: note, address: address, avatarData: avatarData, logoData: logoData, other: other)
        
        if let imageDataUnwrapped = imageData {
            self.cardData = imageDataUnwrapped
        }
        
        self.ckRecordID = ckRecord.recordID
        self.parentCKReference = parentCKReference
    }
    
    public func updateCKRecordLocally(record: inout CKRecord) {
        record.setValue(name, forKey: Card.nameKey)
        record.setValue(title, forKey: Card.titleKey)
        record.setValue(cell, forKey: Card.cellKey)
        record.setValue(email, forKey: Card.emailKey)
        record.setValue(template.rawValue, forKey: Card.templateKey)
        record.setValue(companyName, forKey: Card.companyNameKey)
        record.setValue(note, forKey: Card.noteKey)
        record.setValue(address, forKey: Card.addressKey)
        record.setValue(avatarData, forKey: Card.avatarDataKey)
        let logoDataAsset = CardController.shared.createCKAsset(for: logoData)
        record.setValue(logoDataAsset, forKey: Card.logoDataKey)
        record.setValue(other, forKey: Card.otherKey)
        
        record.setValue(parentCKReference, forKey: Card.parentKey)
        
        self.ckRecordID = record.recordID
    }
}

func ==(lhs: Card, rhs: Card) -> Bool {
    if lhs.name != rhs.name { return false }
    if lhs.title != rhs.title { return false }
    if lhs.cell != rhs.cell { return false }
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
