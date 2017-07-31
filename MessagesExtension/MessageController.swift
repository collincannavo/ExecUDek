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
import SharedExecUDek

class MessageController {
    
    static func prepareToSendPNG(with data: Data, in conversation: MSConversation) {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let directory = directories.first else { return }
        let directoryNSString = directory as NSString
        let path = directoryNSString.appendingPathComponent("cardPhoto.png")
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        
        conversation.insertAttachment(URL(fileURLWithPath: path), withAlternateFilename: nil, completionHandler: nil)
    }
    
    static func prepareToSendCard(with recordID: CKRecordID, from cell: CommonCardTableViewCell, in conversation: MSConversation) {
        guard let messageURL = urlForMessage(with: recordID) else { return }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "You've receieved a business card!"
        if let data = UIViewToPNG.uiViewToPNG(for: cell) {
            layout.image = UIImage(data: data)
        }
        
        message.layout = layout
        message.url = messageURL
        
        conversation.insert(message) { (error) in
            if let error = error { NSLog("Error encountered inserting message into conversation: \(error.localizedDescription)"); return }
        }
    }
    
    static func urlForMessage(with recordID: CKRecordID) -> URL? {
        var urlComponents = URLComponents()
        
        let queryItems = [URLQueryItem(name: Constants.receivedCardRecordIDKey, value: "\(recordID)")]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
    
    static func receiveAndParseMessage(_ message: MSMessage) {
        guard let url = message.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            let recordIDQueryItem = urlComponents.queryItems?.first,
            let recordIDString = recordIDQueryItem.value else { return }
        
        let recordID = CKRecordID(recordName: recordIDString)
        CloudKitContoller.shared.fetchRecord(with: recordID) { (record, error) in
            if let error = error { NSLog("Error encountered fetching received Card record: \(error.localizedDescription)"); return }
            guard let record = record else { NSLog("The returned received Card record from the extension is nil"); return }
            guard let card = Card(ckRecord: record) else { NSLog("Could not create Card object from received record"); return }
            guard let currentPerson = PersonController.shared.currentPerson else { NSLog("Current person object is nil"); return }
            
            PersonController.shared.addCard(card, to: currentPerson)
        }
    }
}
