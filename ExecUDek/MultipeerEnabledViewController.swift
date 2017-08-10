//
//  MultipeerEnabledViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/8/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SharedExecUDek

class MultipeerEnabledViewController: UIViewController, MultipeerControllerDelegate {
    
    var selectedCard: Card?
    var customNavigationController: CustomNavigationController {
        return self.navigationController as? CustomNavigationController ?? CustomNavigationController()
    }
    
    var waitingOnCardTransmissionStep = false {
        didSet {
            DispatchQueue.main.async {
                self.updateActivityIndicator()
            }
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var indicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView = ActivityIndicator.indicatorView(with: activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MultipeerController.shared.delegate = self
        
        switch MultipeerController.shared.connectionStatus {
        case .notConnected:
            customNavigationController.hideMultipeerToolbar()
            customNavigationController.updateMultipeerToolbar(with: "Not connected")
        case .advertising:
            customNavigationController.showMultipeerToolbar()
            customNavigationController.updateMultipeerToolbar(with: "Advertising...")
        case .browsing:
            customNavigationController.showMultipeerToolbar()
            customNavigationController.updateMultipeerToolbar(with: "Browsing...")
        case .connecting:
            customNavigationController.showMultipeerToolbar()
            customNavigationController.updateMultipeerToolbar(with: "Connecting...")
        case .connected:
            let peerID = MultipeerController.shared.connectedPeer?.displayName ?? "Unknown device"
            customNavigationController.showMultipeerToolbar()
            customNavigationController.updateMultipeerToolbar(with: "Connected to \(peerID)")
        }
    }

    func didReceiveData(_ data: Data, from peerID: MCPeerID) {
        
        let alertController = UIAlertController(title: "Received Card", message: "You've received a Card. Would you like to accept it?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.receiveData(data, from: peerID)
            self.waitingOnCardTransmissionStep = true
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            // Completion stuff
            self.waitingOnCardTransmissionStep = false
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true) {}
        }
    }
    
    func didDiscoverPeer(_ peerID: MCPeerID) {
        let title = "Discovered a Peer!"
        let message = "Would you like to connect with \(peerID.displayName)?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.invitePeer(peerID)
            self.waitingOnCardTransmissionStep = true
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            MultipeerController.shared.cancelSession()
            self.customNavigationController.hideMultipeerToolbar()
            self.waitingOnCardTransmissionStep = false
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didReceiveInvitation(from peerID: MCPeerID, in session: MCSession, with invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let alert = UIAlertController(title: "Invitation for a business card", message: "from \(peerID.displayName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
            invitationHandler(true, session)
            self.waitingOnCardTransmissionStep = true
        })
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel) { action in
            invitationHandler(false, session)
            MultipeerController.shared.cancelSession()
            self.customNavigationController.hideMultipeerToolbar()
            self.waitingOnCardTransmissionStep = false
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentSendCardAlert(for peerID: MCPeerID) {
        let alertController = UIAlertController(title: "Send Card", message: "Would you like to send the selected Card?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.sendData(to: peerID)
            self.waitingOnCardTransmissionStep = true
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            MultipeerController.shared.cancelSession()
            self.customNavigationController.hideMultipeerToolbar()
            self.waitingOnCardTransmissionStep = false
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) {}
    }
    
    func presentUnableToSaveAlert(with completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Unable to Save Card", message: "This card already exists in your wallet", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(dismissAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true) { (success) in
                MultipeerController.shared.cancelSession()
                self.customNavigationController.hideMultipeerToolbar()
            }
        }
    }
    
    func presentFailedCardReceiveAlert() {
        self.waitingOnCardTransmissionStep = false
        let alertController = UIAlertController(title: "Failed to Receive Card", message: "The Card object could not be properly received", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true) { (success) in
                MultipeerController.shared.cancelSession()
                self.customNavigationController.hideMultipeerToolbar()
            }
        }
    }
    
    func didFinishReceivingCard(from peerID: MCPeerID) {
        self.waitingOnCardTransmissionStep = false
        let title = "Successfully Received Card!"
        let message = "Card was successfully received from \(peerID.displayName)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in }
        alertController.addAction(dismissAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true) {}
        }
    }
    
    func connectionStatusDidChange(to connectionStatus: ConnectionStatus, with peerIDName: String?) {
        
        let peerIDNameUnwrapped = peerIDName ?? "Unknown device"
        let toolBarText: String
        
        switch connectionStatus {
        case .notConnected:
            toolBarText = "Not connected"
            waitingOnCardTransmissionStep = false
        case .advertising:
            toolBarText = "Advertising..."
            waitingOnCardTransmissionStep = true
        case .browsing:
            toolBarText = "Browsing..."
            waitingOnCardTransmissionStep = true
        case .connecting:
            toolBarText = "Connecting..."
        case .connected:
            toolBarText = "Connected to \(peerIDNameUnwrapped)"
        }
        
        DispatchQueue.main.async {
            self.customNavigationController.updateMultipeerToolbar(with: toolBarText)
        }
    }
    
    func browseMultipeer() {
        customNavigationController.browseSelected()
    }
    
    func sessionDidBecomeNotConnected() {
        DispatchQueue.main.async {
            self.customNavigationController.hideMultipeerToolbar()
        }
    }
    
    func updateActivityIndicator() {
        if waitingOnCardTransmissionStep {
            activityIndicator.startAnimating()
            ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        } else {
            activityIndicator.stopAnimating()
            ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
        }
    }
}
