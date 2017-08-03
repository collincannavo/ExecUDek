//
//  MessageController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/29/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import Messages
import CloudKit

public class MessageController {
    
    public static func prepareToSendPNG(with data: Data, in conversation: MSConversation) {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let directory = directories.first else { return }
        let directoryNSString = directory as NSString
        let path = directoryNSString.appendingPathComponent("cardPhoto.png")
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        
        conversation.insertAttachment(URL(fileURLWithPath: path), withAlternateFilename: nil, completionHandler: nil)
    }
    
    public static func prepareToSendCard(with recordID: CKRecordID, from cell: CommonCardTableViewCell, in conversation: MSConversation) {
        guard let messageURL = urlForMessage(with: recordID) else { return }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "You've received a business card!"
        if let data = UIViewToPNG.uiViewToPNG(for: cell) {
            layout.image = UIImage(data: data)
        }
        
        message.layout = layout
        message.url = messageURL
        
        conversation.insert(message) { (error) in
            if let error = error { NSLog("Error encountered inserting message into conversation: \(error.localizedDescription)"); return }
        }
    }
    
    public static func createMessage(with recordID: CKRecordID, from cell: CommonCardTableViewCell) -> MSMessage? {
        guard let messageURL = urlForMessage(with: recordID) else { return nil }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "You've received a business card!"
        if let data = UIViewToPNG.uiViewToPNG(for: cell) {
            layout.image = UIImage(data: data)
        }
        
        message.layout = layout
        message.url = messageURL
        
        return message
    }
    
    public static func urlForMessage(with recordID: CKRecordID) -> URL? {
        var urlComponents = URLComponents()
        
        let queryItems = [URLQueryItem(name: Constants.receivedCardRecordIDKey, value: "\(recordID.recordName)")]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
    
    public static func receiveAndParseMessage(_ message: MSMessage, with completion: @escaping (Card?) -> Void) {
        guard let url = message.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            let recordIDQueryItem = urlComponents.queryItems?.first,
            let recordIDString = recordIDQueryItem.value else { completion(nil); return }
        
        let recordID = CKRecordID(recordName: recordIDString)
        CloudKitContoller.shared.fetchRecord(with: recordID) { (record, error) in
            
            var receivedCard: Card? = nil
            defer { completion(receivedCard) }
            
            if let error = error { NSLog("Error encountered fetching received Card record: \(error.localizedDescription)"); return }
            guard let record = record else { NSLog("The returned received Card record from the extension is nil"); return }
            guard let card = Card(ckRecord: record) else { NSLog("Could not create Card object from received record"); return }
            
            card.ckRecordID = recordID
            receivedCard = card
        }
    }
    
    public static func save(_ card: Card, with completion: @escaping (Bool) -> Void) {
        
        guard let currentPerson = PersonController.shared.currentPerson else {
            NSLog("Current person object is nil")
            completion(false)
            return
        }
        
        let currentReceivedCardsRecordIDs = currentPerson.receivedCards.map({ $0.recordID })
        
        guard let cardRecordID = card.ckRecordID,
            !currentReceivedCardsRecordIDs.contains(cardRecordID) else { completion(false); return }
        
        PersonController.shared.addCard(card, to: currentPerson)
        
        guard let reference = card.ckReference else { completion(false); return }
        PersonController.shared.addCardReference(reference, to: currentPerson)
        
        guard let personRecordID = currentPerson.cKRecordID else { completion(false); return }
        
        CloudKitContoller.shared.updateRecord(recordID: personRecordID)
        completion(true)
    }
}
