//
//  MultiPeerConnectivity.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SharedExecUDek

class MPC : NSObject {
    static var shared = MPC()
    
    var peerID = MCPeerID()
    var session = MCSession()
    var browser = MCBrowserViewController()
    var advertiser = MCAdvertiserAssistant()
    var delegate: MPCDelegate?
    
    override init() {
        super.init()
        setupPeer(with: UIDevice.current.name)
        setupSession()
        advertiseSelf(shouldAdvertise: true)
        
    }
    
    func setupPeer(with displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession(){
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrowser(){
        browser = MCBrowserViewController(serviceType: "sending-cards", session: session)
    }
    
    func advertiseSelf(shouldAdvertise: Bool) {
        guard shouldAdvertise else {
            advertiser.stop()
            return
    }
        advertiser = MCAdvertiserAssistant(serviceType: "sending-cards", discoveryInfo: nil, session: session)
        advertiser.start()
    
    }
    
    func send(data: Data, peerID: MCPeerID, session: MCSessionSendDataMode) {
        
    }
    
}
    

protocol MPCDelegate {
    func changed(state: MCSessionState, of peer: MCPeerID)
    func received(data: Data, from peer: MCPeerID)
}

extension MPC: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        return certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
       
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        
        unarchiver.requiresSecureCoding = true
        
        let card = unarchiver.decodeObject()
        
        unarchiver.finishDecoding()
        
        let person = PersonController.shared.currentPerson
        
        guard let newPerson = person else { return }
        
        PersonController.shared.addCard(card as! Card, to: newPerson)
        
        print("\(String(describing: card))")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
      
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    
}
