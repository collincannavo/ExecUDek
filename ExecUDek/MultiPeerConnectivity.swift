//
//  MultiPeerConnectivity.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//w

import Foundation
import MultipeerConnectivity
import SharedExecUDek
import CloudKit

extension UserProfileTableViewController {
    
    // MARK:- Action
    func searchAction() {
        isMultipeerSender = true
        self.startBrowsing()
    }
    
    func disconnectAction() {
        self.session.disconnect()
        isMultipeerSender = false
    }
    
    // MARK:- Private
    func startBrowsing() {
        self.startAdvertising()
        self.browser = MCNearbyServiceBrowser(peer: self.session.myPeerID, serviceType: "sending-card")
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
        self.updateState(.browsing)
    }
    
    func stopBrowsing() {
        self.browser?.stopBrowsingForPeers()
        self.browser = nil
    }
    
    func startAdvertising() {
        self.stopBrowsing()
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.session.myPeerID, discoveryInfo: nil, serviceType: "sending-card")
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
        self.updateState(.advertising)
    }
    
    func stopAdvertising() {
        self.advertiser?.stopAdvertisingPeer()
        self.advertiser = nil
    }
    
    enum State {
        case notConnected
        case browsing
        case advertising
        case connecting
        case connected
    }
    
    func updateState(_ state: State, peerName: String? = nil) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let navigationController = self.navigationController as? CustomNavigationController {
                    navigationController.updateMultipeerToolbar(with: "Not connected")
                }
                self.isMultipeerSender = false
            case .browsing:
                if let navigationController = self.navigationController as? CustomNavigationController {
                    navigationController.updateMultipeerToolbar(with: "Browsing...")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .advertising:
                if let navigationController = self.navigationController as? CustomNavigationController {
                    navigationController.updateMultipeerToolbar(with: "Advertising...")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .connecting:
                if let navigationController = self.navigationController as? CustomNavigationController {
                    navigationController.updateMultipeerToolbar(with: "Connecting...")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .connected:
                self.stopBrowsing()
                self.stopAdvertising()
                
                if let navigationController = self.navigationController as? CustomNavigationController {
                    let peerNameUnwrapped = peerName ?? "Unknown Name"
                    navigationController.updateMultipeerToolbar(with: "Connected to \(peerNameUnwrapped)")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK:- MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            self.updateState(.notConnected)
        case .connecting:
            self.updateState(.connecting)
        case .connected:
            self.updateState(.connected, peerName: peerID.displayName)
            if isMultipeerSender { presentSendCardAlert(for: peerID) }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        presentReceiveCardAlert(for: data, from: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
    
    // MARK; - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        presentDiscoveredPeerAlert(peerName: peerID.displayName) {
            if self.isMultipeerSender { browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10) }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        isMultipeerSender = false
    }
    
    // MARK:- MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let alert = UIAlertController(title: "Invitation for a business card", message: "from \(peerID.displayName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
            invitationHandler(true, self.session)
        })
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel) { action in
            invitationHandler(false, self.session)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSendCardAlert(for peerID: MCPeerID) {
        let alertController = UIAlertController(title: "Send Card", message: "Would you like to send the selected Card?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.sendData(to: peerID)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) {}
    }
    
    func sendData(to peerID: MCPeerID) {
        guard let selectedCard = selectedCard,
            let cardRecordID = selectedCard.ckRecordID,
            let data = cardRecordID.recordName.data(using: .utf8) else { return }

        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            print("Error while sending data through multipeer: \(error.localizedDescription)")
        }
    }
    
    func presentReceiveCardAlert(for data: Data, from peerID: MCPeerID) {
        let alertController = UIAlertController(title: "Received Card", message: "You've received a Card. Would you like to accept it?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.receiveData(data, from: peerID)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            // Completion stuff
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) {
            // Completion stuff
        }
    }
    
    func receiveData(_ data: Data, from peerID: MCPeerID) {
        guard let cardRecordIDName = String(data: data, encoding: .utf8) else { presentFailedCardReceiveAlert(); return }
        
        let cardRecordID = CKRecordID(recordName: cardRecordIDName)
        
        CloudKitContoller.shared.fetchRecord(with: cardRecordID) { (record, error) in
            if let error = error { NSLog("Error encountered while fetching received multipeer Card: \(error.localizedDescription)"); return }
            guard let record = record else { NSLog("Data fetched for received multipeer Card is nil"); return }
            guard let card = Card(ckRecord: record) else { NSLog("Could not construct Card object from received multipeer card record ID"); return }
            
            MessageController.save(card) { (success) in
                if !success {
                    self.presentUnableToSaveAlert {}
                }
            }
        }
    }
    
    func presentUnableToSaveAlert(with completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Unable to Save Card", message: "This card already exists in your wallet", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentFailedCardReceiveAlert() {
        let alertController = UIAlertController(title: "Failed to Receive Card", message: "The Card object could not be properly received", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentDiscoveredPeerAlert(peerName: String, completion: @escaping () -> Void) {
        let title = "Discovered a Peer!"
        let message = "Would you like to connect with \(peerName)?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            completion()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func cancelSession() {
        disconnectAction()
        stopBrowsing()
        stopAdvertising()
    }
}
