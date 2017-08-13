//
//  MultipeerController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/7/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SharedExecUDek
import CloudKit

class MultipeerController: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    static let shared = MultipeerController()
    weak var delegate: MultipeerControllerDelegate?
    
    var connectionStatus: ConnectionStatus = .notConnected
    var isMultipeerSender = false
    let session = MCSession(peer: MCPeerID(displayName: UIDevice.current.name), securityIdentity: nil, encryptionPreference: .none)
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var connectedPeer: MCPeerID?
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    // MARK:- Action
    func searchAction() {
        isMultipeerSender = true
        delegate?.browseMultipeer()
        self.startBrowsing()
    }
    
    func disconnectAction() {
        session.disconnect()
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
    
    func updateState(_ state: ConnectionStatus, peerName: String? = nil) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.delegate?.connectionStatusDidChange(to: state, with: nil)
                self.isMultipeerSender = false
                self.connectionStatus = state
            case .browsing, .advertising, .connecting:
                self.delegate?.connectionStatusDidChange(to: state, with: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.connectionStatus = state
            case .connected:
                let peerNameUnwrapped = peerName ?? "Unknown device"
                self.stopBrowsing()
                self.stopAdvertising()
                self.delegate?.connectionStatusDidChange(to: state, with: peerNameUnwrapped)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.connectionStatus = state
            }
        }
    }
    
    // MARK:- MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            self.updateState(.notConnected)
            delegate?.sessionDidBecomeNotConnected()
            connectedPeer = nil
        case .connecting:
            self.updateState(.connecting)
            connectedPeer = nil
        case .connected:
            self.updateState(.connected, peerName: peerID.displayName)
            connectedPeer = peerID
            if isMultipeerSender {
                DispatchQueue.main.async {
                    self.delegate?.presentSendCardAlert(for: peerID)
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.delegate?.didReceiveData(data, from: peerID)
        }
    }
    
    // MARK; - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            self.delegate?.didDiscoverPeer(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        isMultipeerSender = false
    }
    
    // MARK:- MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.delegate?.didReceiveInvitation(from: peerID, in: self.session, with: invitationHandler)
        }
    }
    
    func sendData(to peerID: MCPeerID) {
        guard let selectedCard = delegate?.selectedCard,
            let cardRecordID = selectedCard.ckRecordID,
            let data = cardRecordID.recordName.data(using: .utf8) else { return }
        
        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            print("Error while sending data through multipeer: \(error.localizedDescription)")
        }
    }
    
    func receiveData(_ data: Data, from peerID: MCPeerID) {
        guard let cardRecordIDName = String(data: data, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.presentFailedCardReceiveAlert()
            }
            return
        }
        
        let cardRecordID = CKRecordID(recordName: cardRecordIDName)
        
        CloudKitContoller.shared.fetchRecord(with: cardRecordID) { (record, error) in
            if let error = error { NSLog("Error encountered while fetching received multipeer Card: \(error.localizedDescription)"); return }
            guard let record = record else { NSLog("Data fetched for received multipeer Card is nil"); return }
            guard let card = Card(ckRecord: record) else { NSLog("Could not construct Card object from received multipeer card record ID"); return }
            
            MessageController.save(card) { (success) in
                if !success {
                    DispatchQueue.main.async {
                        self.delegate?.presentUnableToSaveAlert {}
                    }
                } else {
                    self.delegate?.didFinishReceivingCard(from: peerID)
                }
                
                self.cancelSession()
            }
        }
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        if self.isMultipeerSender {
            browser?.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
        }
    }
    
    func presentFailedCardReceiveAlert() {
        delegate?.presentFailedCardReceiveAlert()
    }
 
    func cancelSession() {
        disconnectAction()
        stopBrowsing()
        stopAdvertising()
        self.updateState(.notConnected)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
}

protocol MultipeerControllerDelegate: class {
    var customNavigationController: CustomNavigationController { get }
    var selectedCard: Card? { get }
    func didReceiveData(_ data: Data, from peerID: MCPeerID)
    func didDiscoverPeer(_ peerID: MCPeerID)
    func didReceiveInvitation(from peerID: MCPeerID, in session: MCSession, with invitationHandler: @escaping (Bool, MCSession?) -> Void)
    func presentSendCardAlert(for peerID: MCPeerID)
    func presentUnableToSaveAlert(with completion: @escaping () -> Void)
    func presentFailedCardReceiveAlert()
    func didFinishReceivingCard(from peerID: MCPeerID)
    func connectionStatusDidChange(to connectionStatus: ConnectionStatus, with peerIDName: String?)
    func browseMultipeer()
    func sessionDidBecomeNotConnected()
}
