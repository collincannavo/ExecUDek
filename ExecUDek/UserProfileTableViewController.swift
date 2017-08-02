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
import MessageUI

class UserProfileTableViewController: UITableViewController, ActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let session = MCSession(peer: MCPeerID(displayName: UIDevice.current.name))
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    
    var searchButton: UIBarButtonItem?
    var disconnectButton: UIBarButtonItem?
    var card = CommonCardTableViewCell()
    var selectedCard: Card?

    @IBAction func addNewCardButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped! \n\n\n\n\n")
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CommonCardTableViewCell else { return }
        
        if let card = cell.card {
            selectedCard = card
            
            performSegue(withIdentifier: "editCardFromUser", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)

        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(cardXIB, forCellReuseIdentifier: "cardCell")
        
        self.session.delegate = self
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell,
            let newCard = card else { return CommonCardTableViewCell() }
        
        if let cellPhone = newCard.cell {
            cell.cellLabel.text = "\(cellPhone)"
        }
        cell.actionSheetDelegate = self
        cell.nameLabel.text = newCard.name
        cell.titleLabel.text = newCard.title
        cell.cellLabel.text = "\(String(describing: newCard.cell))"
        cell.emailLabel.text = newCard.email
        cell.card = newCard
        if let data = card?.logoData {
            let image = UIImage(data: data)
            
            cell.photoButton.setBackgroundImage(image, for: .disabled)
            cell.photoButton.setTitle("", for: .disabled)
        }
        
        cell.disablePhotoButton()
        
        setupCardTableViewCell(cell)
        
        return cell
    }
    
    // MARK: - MF message view controller delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
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
                destinationVC.card = selectedCard
            }
        }
    }
    
    func setupCardTableViewCell(_ cell: CommonCardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
    
    func refresh() {
        tableView.reloadData()
    }
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CommonCardTableViewCell) {
        let alertController = UIAlertController(title: "Share Business Card", message: "", preferredStyle: .actionSheet)
        
        let iMessagesButton = UIAlertAction(title: "iMessage", style: .default) { (_) in
            guard let indexPath = self.tableView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            self.presentSMSInterface(for: card, with: cell)
        }
        
        let multiShareButton = UIAlertAction(title: "MultiPeer Connect", style: .default) { (_) in
            guard let indexPath = self.tableView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            self.searchAction()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(iMessagesButton)
        alertController.addAction(multiShareButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentSMSUnavailableAlert() {
        let alertController = UIAlertController(title: "SMS Services Unavailable", message: "Download iMessages and try again", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentSMSInterface(for card: Card, with cell: CommonCardTableViewCell) {
        guard MFMessageComposeViewController.canSendText(),
            let cardRecordID = card.ckRecordID,
            let message = MessageController.createMessage(with: cardRecordID, from: cell) else { presentSMSUnavailableAlert(); return }
    
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.message = message
        self.present(composeVC, animated: true, completion: nil)
    }
}

