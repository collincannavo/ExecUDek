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

extension UserProfileTableViewController {
    
    // MARK:- Action
    func searchAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Look for devices", style: .default) { action in
            self.startBrowsing()
        })
        actionSheet.addAction(UIAlertAction(title: "Make device available", style: .default) { action in
            self.startAdvertising()
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func disconnectAction() {
        self.session.disconnect()
    }
    
    // MARK:- Private
    fileprivate func startBrowsing() {
        self.startAdvertising()
        self.browser = MCNearbyServiceBrowser(peer: self.session.myPeerID, serviceType: "sending-card")
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
        self.updateState(.browsing)
    }
    
    fileprivate func stopBrowsing() {
        self.browser?.stopBrowsingForPeers()
        self.browser = nil
    }
    
    fileprivate func startAdvertising() {
        self.stopBrowsing()
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.session.myPeerID, discoveryInfo: nil, serviceType: "sending-card")
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
        self.updateState(.advertising)
    }
    
    fileprivate func stopAdvertising() {
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
                print("  + state = Not Connected")
                self.navigationItem.title = "Not Connected"
                self.navigationItem.rightBarButtonItem = self.searchButton
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .browsing:
                print("  + state = Browsing")
                self.navigationItem.title = "Browsing..."
                self.navigationItem.rightBarButtonItem = self.searchButton
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .advertising:
                print("  + state = Advertising")
                self.navigationItem.title = "Advertising..."
                self.navigationItem.rightBarButtonItem = self.searchButton
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .connecting:
                print("  + state = Connecting")
                self.navigationItem.title = "Connecting..."
                self.navigationItem.rightBarButtonItem = nil
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .connected:
                print("  + state = Connected")
                self.stopBrowsing()
                self.stopAdvertising()
                self.navigationItem.title = peerName ?? "(Unknown Name)"
                self.navigationItem.rightBarButtonItem = self.disconnectButton
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
            presentSendCardAlert(for: peerID)
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        presentReceiveCardAlert(for: data, from: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    
    // MARK; - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
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
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            // Completion stuff
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) { 
            // Completion stuff
        }
    }
    
    func sendData(to peerID: MCPeerID) {
        guard let selectedCard = selectedCard else { return }
        let cardData = NSKeyedArchiver.archivedData(withRootObject: selectedCard)
        do {
            try session.send(cardData, toPeers: [peerID], with: .reliable)
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
        guard let card = NSKeyedUnarchiver.unarchiveObject(with: data) as? Card else { return }
        print("\(card.name)")
    }
}



















