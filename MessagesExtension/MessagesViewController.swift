//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import Messages
import SharedExecUDek
import NotificationCenter

class MessagesViewController: MSMessagesAppViewController, CardReceivedViewControllerDelegate {
    
    var currentCard: Card?
    var currentMessage: MSMessage?
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        CloudKitContoller.shared.fetchCurrentUser { (success, person) in
            if success {
                if person != nil {
                    CardController.shared.fetchPersonalCards(with: { (success) in
                        DispatchQueue.main.async {
                            person?.initialPersonalCardsFetchComplete = true
                            NotificationCenter.default.post(name: Constants.personalCardsFetchedNotification, object: self)
                        }
                    })
                } else {
                    CloudKitContoller.shared.createUserWith(name: "Test", completion: { (_) in } )
                }
            }
        }
        
        currentMessage = conversation.selectedMessage
        
        DispatchQueue.main.async {
            self.presentViewController(for: conversation, with: .expanded, forReceivedMessage: true)
        }
        
        if let currentMessage = currentMessage {
            MessageController.receiveAndParseMessage(currentMessage) { (card) in
                self.currentCard = card
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Constants.receivedMessagesCardFetchedNotification, object: self)
                }
            }
        } else {
            presentViewController(for: conversation, with: presentationStyle, forReceivedMessage: false)
        }
    }

    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        super.didSelect(message, conversation: conversation)
        
        MessageController.receiveAndParseMessage(message) { (card) in
            self.currentCard = card
            
            DispatchQueue.main.async {
                self.presentViewController(for: conversation, with: .expanded, forReceivedMessage: true)
            }
        }
    }
    
    // MARK: - Card received view controller delegate
    func userDidHandleReceivedCard() {
        dismiss()
    }
    
    // MARK: - Child view controller presentation
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle, forReceivedMessage: Bool) {
        
        removeAllChildViewControllers()
        
        let childController: UIViewController
        
        if forReceivedMessage {
            guard let childControllerReceiveMessage = storyboard?.instantiateViewController(withIdentifier: "receivedCardViewController") as? CardReceivedViewController else { fatalError("Could not instantiate card received view controller") }
            
            childControllerReceiveMessage.card = currentCard
            childControllerReceiveMessage.delegate = self
            childController = childControllerReceiveMessage
        } else {
            guard let childControllerCompactView = storyboard?.instantiateViewController(withIdentifier: "extCardsCompactVC") as? EXTCardsCompactViewController else { fatalError("Could not instantiate cards compact view controller") }
            
            childControllerCompactView.conversation = conversation
            childController = childControllerCompactView
        }
        
        addChildViewController(childController)
        childController.view.frame = view.bounds
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childController.view)
        
        NSLayoutConstraint.activate([
                childController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                childController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                childController.view.topAnchor.constraint(equalTo: view.topAnchor),
                childController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        childController.didMove(toParentViewController: self)
    }
    
    func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
}
