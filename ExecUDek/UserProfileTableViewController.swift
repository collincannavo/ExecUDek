//
//  UserProfileTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek
import NotificationCenter
import MultipeerConnectivity

class UserProfileTableViewController: UITableViewController, UIActionSheetDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let session = MCSession(peer: MCPeerID(displayName: UIDevice.current.name))
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    
    var searchButton: UIBarButtonItem?
    var disconnectButton: UIBarButtonItem?
    
    @IBAction func addNewCardButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)

        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(cardXIB, forCellReuseIdentifier: "cardCell")
        
        self.session.delegate = self
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchAction))
        self.disconnectButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.disconnectAction))
        
        self.updateState(.notConnected)
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell, let newCard = card else {
            return CommonCardTableViewCell()
        }
        
        cell.nameLabel.text = newCard.name
        cell.titleLabel.text = newCard.title
        cell.cellLabel.text = "\(String(describing: newCard.cell))"
        cell.emailLabel.text = newCard.email
        cell.photoButton.backgroundImage(for: UIControlState())
        
        setupCardTableViewCell(cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped! \n\n\n\n\n")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
            }
        }
        if segue.identifier == "editCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
            }
        }
    }
    
    func setupCardTableViewCell(_ cell: CommonCardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
    
    func refresh() {
        tableView.reloadData()
    }
}

