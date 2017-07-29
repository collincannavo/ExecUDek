//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    // MARK: - Child view controller presentation
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        
        removeAllChildViewControllers()
        
        guard let childController = storyboard?.instantiateViewController(withIdentifier: "extCardsCompactVC") as? EXTCardsCompactViewController else { fatalError("Could not instantiate cards compact view controller") }
        
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
        childController.conversation = conversation
    }
    
    func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }

}

























