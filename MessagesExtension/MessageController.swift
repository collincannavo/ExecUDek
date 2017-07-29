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

class MessageController {
    
    static func prepareToSendPNG(with data: Data, in conversation: MSConversation) {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let directory = directories.first else { return }
        let directoryNSString = directory as NSString
        let path = directoryNSString.appendingPathComponent("cardPhoto.png")
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        
        conversation.insertAttachment(URL(fileURLWithPath: path), withAlternateFilename: nil, completionHandler: nil)
    }
    
    static func prepardToSendCard(with recordID: CKRecordID, in conversation: MSConversation) {
        guard let messageURL = urlForMessage(with: recordID) else { return }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "You've receieved a business card!"
        layout.image = #imageLiteral(resourceName: "businessCard1")
        
        message.layout = layout
        message.url = messageURL
        
        conversation.insert(message) { (error) in
            if let error = error { NSLog("Error encountered inserting message into conversation: \(error.localizedDescription)"); return }
        }
    }
    
    static func urlForMessage(with recordID: CKRecordID) -> URL? {
        var urlComponents = URLComponents()
        
        let queryItems = [URLQueryItem(name: "receivedCardRecordID", value: "\(recordID)")]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
}
